from setuptools import setup, find_packages

VERSION = '0.0.0'
DESCRIPTION = 'build tool within python'
LONG_DESCRIPTION = 'Very limited and not very useful build tool within python'

setup(
    name='python_tasker',
    version=VERSION,
    description=DESCRIPTION,
    long_description=LONG_DESCRIPTION,
    packages = find_packages(),
    install_requires=['networkx'],
    keywords=['python','build tool', 'target', 'phony'],
    classifiers = ["Development Status :: 3 - Alpha",
                   "Intended Audience :: EDA",
                   "Programming Language :: Python :: 3",
                   "Operating System :: Linux"
                   ]
)
