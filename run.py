import os
import sys

import phonytask as pt
import taskenv as te
from edalize import *

work_root = 'build'

class EdaToolBuildWrapper:
    edatool = None
    def __init__(self, edatool):
        self.edatool = edatool
    def run(self, name, output_dir):
        self.edatool.build()

class EdaToolConfigWrapper:
    edatool = None
    def __init__(self, edatool):
        self.edatool = edatool
    def run(self, name, output_dir):
        self.edatool.configure()

class EdaToolRunWrapper:
    edatool = None
    def __init__(self, edatool):
        self.edatool = edatool
    def run(self, name, output_dir):
        self.edatool.run()

def create_edam_task(tool, edam, work_root):
    print(edam)
    backend = get_edatool(tool)(edam=edam, work_root=work_root)
    os.makedirs(work_root)
    configname = 'configure_' + edam['name']
    config = pt.phonytask(name=configname, task=EdaToolConfigWrapper(backend), output_dir=work_root)
    buildname = 'build_' + edam['name']
    build = pt.phonytask(name=buildname, task=EdaToolBuildWrapper(backend), output_dir=work_root, dependencies = [configname])
    runname = 'run_' + edam['name']
    run = pt.phonytask(name=runname, task=EdaToolRunWrapper(backend), output_dir=work_root, dependencies = [buildname])
    return [config, build, run]

def adjust_paths(path_list, dest):
    new_list = []
    for i in path_list:
        copy = i.copy()
        copy['name'] = os.path.relpath(copy['name'], dest)
        new_list.append(copy)
    return new_list


synthfiles = [
    {'name' : os.path.join('verilog', 'hdl','blockram.v'),
     'file_type' : 'verilogSource'},
    {'name' : os.path.join('verilog', 'hdl','bram_std_fifo.v'),
     'file_type' : 'verilogSource'}
    ]

formalfiles = [
    {'name' : os.path.join('verilog', 'formal','formal_bram_std_fifo.v'),
     'file_type' : 'verilogSource'}
    ]
print(formalfiles)

prove_template = [
    {'name' : os.path.join('verilog', 'templates', 'prove_config.sby.j2'),
     'file_type' : 'sbyConfigTemplate'}]
cover_template = [
    {'name' : os.path.join('verilog', 'templates', 'cover_config.sby.j2'),
     'file_type' : 'sbyConfigTemplate'}]


tool = 'symbiyosys'


edam_prove = {
    'files' : adjust_paths(prove_template + formalfiles + synthfiles,
                           os.path.join(work_root, 'formal_prove_bram_std_fifo')),
    'name'  : 'formal_prove_bram_std_fifo',
    'tool_options' : {'tasknames':['prove']},
    'toplevel' : 'formal_bram_std_fifo'
    }
print(formalfiles)

edam_cover = {
    'files' : adjust_paths(cover_template + formalfiles + synthfiles,
                           os.path.join(work_root, 'formal_prove_bram_std_fifo')),
    'name'  : 'formal_cover_bram_std_fifo',
    'tool_options' : {'tasknames':['cover']},
    'toplevel' : 'formal_bram_std_fifo'
    }
print(formalfiles)

tasklist = create_edam_task(tool=tool, edam=edam_prove, work_root=os.path.join(work_root, edam_prove['name']))
tasklist.extend(create_edam_task(tool=tool, edam=edam_cover, work_root=os.path.join(work_root, edam_cover['name'])))
                            

tasker = te.taskenv()
for i in tasklist:
    tasker.add_task(i)
tasker.run_task('run_formal_prove_bram_std_fifo')
tasker.run_task('run_formal_cover_bram_std_fifo')

