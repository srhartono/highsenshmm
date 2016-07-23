## *1. Starting Up:*

- If you are using Windows, then install Linux using wubi (http://wubi.sourceforge.net/faq.php) - this is easiest.
- If you're using Mac/Linux, then open terminal
- In terminal type `git` and enter. If it says something along the line `command not found` then install git from the link below:
    - Mac: https://git-scm.com/download/mac
    - Linux: https://git-scm.com/download/linux
- Then copy paste this below on the terminal to use my default installation path:

```
# Go to home folder
cd

# Copy the highsenshmm software
git clone https://github.com/srhartono/highsenshmm

# It should start download. Once finished, go to highsenshmm folder
cd highsenshmm
```

## *2. Requirements:*
    
__1.__ bedtools v.2.17 (http://bedtools.readthedocs.io/en/latest/content/installation.html)

- To check if you have it or not, in terminal just type `bedtools --version`. 
- If command not found or the version isn't at least v.2.17 then you have to install it.
- To install bedtools copy paste below:
    
    ```
    # go to bedtools folder
    cd bin/bedtools2_25_0/
    
    # make is linux way of installing
    make
    
    # go to main folder
    cd ../../
    ```
    
__2.__ stochhmm v. 0.35 (https://github.com/KorfLab/StochHMM)

- To check if you have it or not, in terminal just type `stochhmm`. 
- If command not found or the version isn't at least v.0.35 then you have to install it.
- To install stochhmm copy paste below in the terminal
    
    ```
    # go to bin folder
    cd bin
    
    # git clone StochHMM
    git clone https://github.com/KorfLab/StochHMM

    # go to StochHMM folder
    cd StochHMM
    
    # configure is to configure the make according to your computer setup
    ./configure
    make
    
    # go to main folder
    cd ../../
    ```

- If stochhmm failed to install, I put some binaries inside `bin` folder for ubuntu or mac which could work

    ```
    #Create stochhmm directory in bin
    mkdir bin/StochHMM/

    #Copy paste stochhmm according to your operating system (mac/ubuntu)
    cp bin/stochhmm_mac_10.9.5 bin/StochHMM/stochhmm
    cp bin/stochhmm_ubuntu_14.04.4 bin/StochHMM/stochhmm
    ```

## *3. Test run:*

To quickly test if everything works do:

`./Pipeline.pl test.txt > test.log`

If it produces an output file (output.txt) then it's success.

Otherwise email me the *test.log* file

## *4. How to run:*

Say we are running this on ZNF420 region (chr19:37518112-37671921) for 4 DRIPc + strand files (provided in this directory)

- Control:  `ExampleZNF420_control_pos.wig`
- Scramble: `ExampleZNF420_scramble_pos.wig`
- Top1A:    `ExampleZNF420_top1A_pos.wig`
- Top1B:    `ExampleZNF420_top1B_pos.wig`

Create a text file using whatever text editor you want (recommended: nano, vim, for mac: textedit, textwrangler) and put all 4 file names, one file per row. Example is `FILES.txt`

```
ExampleZNF420_control_pos.wig
ExampleZNF420_scramble_pos.wig
ExampleZNF420_top1A_pos.wig
ExampleZNF420_top1B_pos.wig
```

Then run Pipeline.pl on the text file, for example:

`./Pipeline.pl FILES.txt > FILES.log`

If there is a green SUCCESS then it's successful, otherwise send me the FILES.log file

This will produce 1 peak file per sample and a combined peak file `output.PEAK`. For example, the above will produce:

```
1. ExampleZNF420_control_pos.peak
2. ExampleZNF420_scramble_pos.peak
3. ExampleZNF420_top1A_pos.peak
4. ExampleZNF420_top1B_pos.peak
5. output.PEAK
```
