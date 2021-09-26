import networkx

class KeyCollisionException(Exception):
    pass

class taskenv:
    G = networkx.DiGraph()
    ptdict = {}
    def init(self):
        self.G = networkx.DiGraph()
        self.ptdict = {}
        
    def add_task(self, task):
        if task.name in self.ptdict.keys():
            raise KeyCollisionException('task named ' + task.name +
                                        'already defined in taskenv')
        else:
            self.ptdict[task.name] = task
            self.G.add_node(task.name)
            for dependency in task.dependencies:
                self.G.add_edge(task.name, dependency)

    def get_tasks(self, name):
        if not (name in self.ptdict.keys()):
            raise KeyError('task ' + name + 'has not been added to taskenv')
        else:
            task_list = []
            for node in self.G.successors(name):
                task_list.extend(self.get_tasks(node))
            task_list.append(name)
            task_list_clean = []
            for i in task_list:
                if i not in task_list_clean:
                    task_list_clean.append(i)
            return task_list_clean
        
                
    def run_task(self, name):        
        if not (name in self.ptdict.keys()):
            raise KeyError('task ' + name + 'has not been added to taskenv')
        task_list = self.get_tasks(name)
        for i in task_list:
            self.ptdict[i].run()
    
