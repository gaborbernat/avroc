import pkgconfig
from Cython.Build import cythonize
from setuptools import Extension, setup

dep = "avro-c"
dep_version = ">=1.10.0"
if pkgconfig.installed(dep, dep_version):
    raise Exception(f"{dep}{dep_version} not found")

avroc_pkg = pkgconfig.parse(dep)
setup(ext_modules=cythonize(Extension(name="_schema", sources=["src/avroc/_schema.pyx"], **avroc_pkg)))
