import pkgconfig
from Cython.Build import cythonize
from setuptools import Extension, setup

dep = "avro-c"
dep_version = ">=1.10.0"
if not pkgconfig.installed(dep, dep_version):
    raise Exception(f"{dep}{dep_version} not found")

avroc_pkg = pkgconfig.parse(dep)
extensions = cythonize(Extension(name="schema", sources=["src/avroc/schema.pyx"], **avroc_pkg))
setup(ext_modules=extensions, language_level="3")
