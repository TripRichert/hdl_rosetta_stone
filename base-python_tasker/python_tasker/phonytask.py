import os

class phonytask:
    input_files = []
    name = ''
    generated_input_files = []
    output_dir = None
    dependencies = []

    task = None
    error = False

    def __init__(self, name, output_dir = None, task = None, input_files = [],  generated_input_files = [], dependencies = []):
        self.name = name
        self.output_dir = output_dir
        self.input_files = input_files
        self.generated_input_files = generated_input_files
        self.dependencies = dependencies
        if task != None:
            if output_dir == None:
                raise ValueError('if task function is specified,'
                                 + 'output directory must be specified')
            self.task = task
    def check_input_files(self):
        for filename in self.input_files:
            if not os.path.isfile(filename):
                return False
        return True
    
    def check_gen_input_files(self):
        for filename in self.generated_input_files:
            if not os.path.isfile(filename):
                return False
        return True
        
    def run(self):
        print('\n******************************************')
        print('Executing ' + self.name)
        if self.output_dir != None:
            print('output_dir: ' + self.output_dir)
        if self.task != None:
            self.task.run(name = self.name, output_dir = self.output_dir)
        print('******************************************\n')

