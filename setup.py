import pkgconfig
from Cython.Build import cythonize
from setuptools import Extension, setup

dep = "avro-c"
dep_version = ">=1.8.0"
if not pkgconfig.installed(dep, dep_version):
    raise Exception(f"{dep}{dep_version} not found")

avroc_pkg = pkgconfig.parse(dep)
extensions = cythonize([Extension("*", sources=["src/avroc/*.pyx"], **avroc_pkg)], language_level="3")
setup(ext_modules=extensions)
