
Clone the repo, checkout the `grace-hopper` branch, then move to the `dsl` path:
```
git@github.com:C2SM/icon-exclaim.git
cd icon-exclaim
git checkout grace-hopper
cd dsl
```

`setup_balfrin{_offline}.sh`:
1. load modules for cuda, eccodes, etc
2. icon4py:
    * untar source code tar ball from `./sources`
    * create and activate venv for gt4py
    * pip install all the dependencies
3. gt4py:
    * untar source code tar ball from `./sources`
4. deactivate the venv from 2
