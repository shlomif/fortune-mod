#! /usr/bin/env python3
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2021 Shlomi Fish < https://www.shlomifish.org/ >
#
# Licensed under the terms of the MIT license.

"""
CI-testing/translate-travis.yml-to-github-actions.py :

This program translates fc-solve's .travis.yml to GitHub actions
and ACT workflows ( https://github.com/nektos/act ).

While ostensibly FOSS, it most probably is not generic enough
for your use cases.

"""

import re

import yaml


def _add_condition_while_excluding_gh_actions(job_dict, is_act):
    """
    See:

    https://github.com/actions/runner/issues/480

    Workflow level `env` does not work properly in all fields. · Issue #480

    """
    if is_act:
        job_dict['if'] = \
            "${{ ! contains(env.ACT_SKIP, matrix.env.WHAT) }}"


def generate(output_path, is_act):
    """docstring for main"""
    env_keys = set()

    def _process_env(env):
        ret = {}
        for line in env:
            m = re.match(
                '\\A([A-Za-z0-9_]+)=([A-Za-z0-9_]+)\\Z',
                line)
            key = m.group(1)
            val = m.group(2)
            assert key not in ret
            ret[key] = val
            env_keys.add(key)
        return ret
    with open("./.travis.yml", "rt") as infh:
        data = yaml.safe_load(infh)
    steps = []
    steps.append({
        "uses": ("actions/checkout@v2"),
        "with": {
            "submodules": "true",
        },
    })
    if 0:
        steps.append({
            "run":
            ("cd workflow ; (ls -lrtA ; false)"), })
    elif 0:
        steps.append({
            "run":
            ("cd . ; (ls -lrtA ; false)"), })
    steps.append({"run": ("sudo apt-get update -qq"), })
    steps.append({
        "run": ("sudo apt-get --no-install-recommends install -y " +
                " ".join(["eatmydata"])
                ),
        }
    )
    steps.append({
        "run": ("sudo eatmydata apt-get --no-install-recommends install -y " +
                " ".join(data['addons']['apt']['packages'])
                ),
        }
    )
    local_lib_shim = 'local_lib_shim() { eval "$(perl ' + \
        '-Mlocal::lib=$HOME/' + \
        'perl_modules)"; } ; local_lib_shim ; '
    for arr in ['before_install', 'install', 'script']:
        steps += [{"run": local_lib_shim + x} for x in data[arr]]
    job = 'test-fc-solve'
    o = {'jobs': {job: {'runs-on': 'ubuntu-latest',
         'steps': steps, }},
         'name': 'use-github-actions', 'on': ['push', ], }
    if 'matrix' in data:
        if 'include' in data['matrix']:
            o['jobs'][job]['strategy'] = {'matrix': {'include': [
                {'env': _process_env(x['env']), }
                for x in data['matrix']['include']
            ], }, }
            o['jobs'][job]['env'] = {
                x: "${{ matrix.env." + x + " }}"
                for x in env_keys
            }
            _add_condition_while_excluding_gh_actions(
                job_dict=o['jobs'][job],
                is_act=is_act,
            )
        else:
            assert False
    with open(output_path, "wt") as outfh:
        # yaml.safe_dump(o, outfh)
        yaml.safe_dump(o, stream=outfh, canonical=False, indent=4, )


def generate_windows_yaml(plat, output_path, is_act):
    """docstring for main"""
    env_keys = set()

    def _process_env(env):
        ret = {}
        for line in env:
            m = re.match(
                '\\A([A-Za-z0-9_]+)=([A-Za-z0-9_]+)\\Z',
                line)
            key = m.group(1)
            val = m.group(2)
            assert key not in ret
            ret[key] = val
            env_keys.add(key)
        return ret
    with open("./.appveyor.yml", "rt") as infh:
        data = yaml.safe_load(infh)
    with open("./CI-testing/gh-actions--" +
              "windows-yml--from-p5-UV.yml", "rt") as infh:
        skel = yaml.safe_load(infh)
    steps = skel['jobs']['perl']['steps']
    while steps[-1]['name'] != 'perl -V':
        steps.pop()

    step = {
        "run": "git config --global core.autocrlf input",
    }
    if 0:
        steps.append(step)
    step = {
        "uses": "cygwin/cygwin-install-action@master",
        "with": {
            # .split(" "),
            "packages": "docbook-xml docbook-xsl doxygen libxml2 libxslt",
        },
    }
    steps.append(step)
    cpanm_step = {
        "name": "install cpanm and mult modules",
        "uses": "perl-actions/install-with-cpanm@v1",
    }
    steps.append(cpanm_step)
    # if True:  # plat == 'x86':
    # if plat == 'x86':
    if True:
        mingw = {
            "name": "Set up MinGW",
            "uses": "egor-tensin/setup-mingw@v2",
            "with": {
                "platform": plat,
            },
        }
        steps.append(mingw)

    # See:
    #
    # https://github.com/sithlord48/blackchocobo/actions/runs/1207252836/workflow#L100
    # https://github.community/t/windows-actions-suddenly-fail-needing-a-nuspec-file/199483
    cpack_fix = {
        "if": "runner.os == 'Windows'",
        "name": "Remove Chocolatey's CPack",
        "run": "Remove-Item -Path " +
        "C:\\ProgramData\\Chocolatey\\bin\\cpack.exe -Force",
    }
    cpack_fix_needed = False
    if cpack_fix_needed:
        steps.append(cpack_fix)

    def _calc_batch_code(cmds):
        cmds = [(x['cmd'] if isinstance(x, dict) else x) for x in cmds]
        batch = ""
        batch += "@echo on\n"
        for k, v in sorted(data['environment']['global'].items()):
            # batch += "SET " + k + "=\"" + v + "\"\n"
            batch += "SET " + k + "=" + v + "\n"
        idx = 0
        if plat == 'x86':
            cmds.insert(idx, "SET CXX=c++")
            cmds.insert(idx, "SET CC=cc")
        elif plat == 'x64':
            cmds.insert(
                idx, "c:\\msys64\\usr\\bin\\bash -lc "
                "\"pacman --noconfirm -Sy mingw-w64-x86_64-libsystre\"")

        for cmd in cmds:
            if cmd.startswith("copy C:\\msys64\\mingw64\\bin" +
                              "\\mingw32-make.exe "):
                continue
            if cmd.startswith("C:\\cygwin64\\setup"):
                continue
            cmd = cmd.replace("cygwin64", "cygwin")
            cmd = cmd.replace("MSYS Makefiles", "MinGW Makefiles")
            if cmd.startswith("cpanm "):
                words = cmd.split(' ')[1:]
                dw = []
                for w in words:
                    if not w.startswith("-"):
                        dw.append(w)
                nonlocal cpanm_step
                cpanm_step['with'] = {"install": "\n".join(dw), }
                continue
            if re.search("copy.*?python\\.exe", cmd):
                continue
            if "strawberry" in cmd:
                continue
            cmd = re.sub("\\S*CMAKE_MAKE_PROGRAM\\S*", "", cmd)
            if "choco install strawberryperl" not in cmd:
                if 0:
                    r = re.sub(
                        "curl\\s+-o\\s+(\\S+)\\s+(\\S+)",
                        "lwp-download \\2 \\1",
                        cmd)
                elif plat == 'x86':
                    if cmd.startswith("perl ../source/run-tests.pl"):
                        continue
                    r = re.sub(
                        "--dbm=kaztree",
                        "--dbm=none",
                        cmd
                    )
                else:
                    r = cmd
                # See:
                # https://serverfault.com/questions/157173
                shim = ''
                if not (r.lower().startswith("set ")):
                    shim = " || ( echo Failed & exit /B 1 )"
                batch += r + shim + "\n"
        return batch

    if 0:
        steps.append({'name': "install code", "run": _calc_batch_code(
            cmds=data['install']), "shell": "cmd", })
    steps.append({
        'name': "install and test_script code",
        "run": _calc_batch_code(
            cmds=(data['install']+data['test_script'])
        ),
        "shell": "cmd",
    })

    def _myfilt(path):
        is32 = ("\\pkg-build\\" in path)
        return (is32 if plat == 'x86' else (not is32))
    skel['name'] = ("windows-x86" if plat == 'x86' else 'windows-x64')
    skel['on'] = ['push']
    with open(output_path, "wt") as outfh:
        # yaml.safe_dump(o, outfh)
        outfh.write(
            "# This file is GENERATED BY\n" +
            "# CI-testing/" +
            "translate-travis.yml-to-github-actions.py\n")
        yaml.safe_dump(skel, stream=outfh, canonical=False, indent=4, )


def main():
    generate(
        output_path=".github/workflows/use-github-actions.yml",
        is_act=False,
    )
    generate(
        output_path=".act-github/workflows/use-github-actions.yml",
        is_act=True,
    )
    if 0:
        generate_windows_yaml(
            plat='x86',
            output_path=".github/workflows/windows-x86.yml",
            is_act=False,
        )
    generate_windows_yaml(
        plat='x64',
        output_path=".github/workflows/windows-x64.yml",
        is_act=False,
    )


if __name__ == "__main__":
    main()
