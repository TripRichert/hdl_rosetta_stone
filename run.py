import os
import os.path

def cpy_file(outputdir, name, inputfile, substitution):
    olddata = ""
    if os.path.exists(outputdir):
        filename = os.path.join(outputdir, name)
        if os.path.isfile(filename):
            with open(filename, 'r') as reader:
                olddata = reader.read()
    else:
        os.mkdir(outputdir)

    with open(inputfile, 'r') as reader:
        rawdata = reader.read()

    data = rawdata
    for key in substitution:
        mystr = '${' + key + '}'
        data = data.replace(mystr, substitution[key])

    if data != olddata:
        filename = os.path.join(outputdir, name)
        with open(filename, 'w') as writer:
            writer.write(data)

def prepare_cocotb_dir(outputdir, name, template_file, prjpath, source_files, simulator, language, pythonfile, topname):
    corrected_source_files = []
    if not prjpath:
        prjpath = os.path.dirname(__file__)
    for filename in source_files:
        if os.path.isabs(filename):
            corrected_source_files.append(filename)
        else:
            corrected_source_files.append(os.path.join(prjpath,filename))

    source_files_string = ''
    for filename in corrected_source_files:
        source_files_string = source_files_string + filename + ' '
    pyname = os.path.splitext(os.path.basename(pythonfile))[0]
    vardict = {}
    vardict['simulator'] = simulator
    vardict['lang'] = language
    vardict['source_files'] = source_files_string
    vardict['LANG'] = language.upper()
    vardict['pyname'] = pyname
    vardict['topname'] = topname

    if not os.path.exists(outputdir):
        os.mkdir(outputdir)

    cpy_file(os.path.join(outputdir, name), pyname + '.py', pythonfile, {})
    cpy_file(os.path.join(outputdir, name), 'makefile', template_file, vardict)

mydir = os.path.dirname(os.path.realpath(__file__))
source_files = [os.path.join('verilog', 'hdl', 'blockram.v'), os.path.join('verilog', 'hdl', 'bram_std_fifo.v')]
prepare_cocotb_dir(outputdir = 'build',
                   name='verilog_bram_std_fifo',
                   template_file=os.path.join('templates', 'makefile.in'),
                   prjpath=mydir,
                   source_files=source_files,
                   simulator='icarus',
                   language='verilog',
                   pythonfile=os.path.join('cocotb_tests', 'test_bram_std_fifo.py'),
                   topname='bram_std_fifo')

source_files = [os.path.join('vhdl', 'hdl', 'blockram.vhdl'), os.path.join('vhdl', 'hdl', 'bram_std_fifo.vhdl')]
prepare_cocotb_dir(outputdir = 'build',
                   name='vhdl_bram_std_fifo',
                   template_file=os.path.join('templates', 'makefile.in'),
                   prjpath=mydir,
                   source_files=source_files,
                   simulator='ghdl',
                   language='vhdl',
                   pythonfile=os.path.join('cocotb_tests', 'test_bram_std_fifo.py'),
                   topname='bram_std_fifo')
