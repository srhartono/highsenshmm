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
    
    1. bedtools v.2.25 (http://bedtools.readthedocs.io/en/latest/content/installation.html)
    
        - To check if you have it or not, in terminal just type `bedtools --version`. 
        - If command not found or the version isn't at least v.2.25 then you have to install it.
        - To install bedtools copy paste below:
    
        ```
        # go to bedtools folder
        cd bin/bedtools2_25_0/
    
        # make is linux way of installing
        make
    
        # go to main folder
        cd ../../
        ```
    
    2. stochhmm v. 0.37(https://github.com/KorfLab/StochHMM)
        - To check if you have it or not, in terminal just type `stochhmm`. 
        - If command not found or the version isn't at least v.0.37 then you have to install it.
        - To install stochhmm copy paste below in the terminal
    
        ```
        # go to bin folder
        cd bin

        # git clone StochHMM
        git clone https://github.com/KorfLab/StochHMM
        
        # configure is to configure the make according to your computer setup
        ./configure
        make
        
        # go to main folder
        cd ../../
        ```


## *3. Running:*

Say we are running this on ZNF420 region (chr19:37518112-37671921) for 4 DRIPc + strand files (provided in this directory)

- Control:  `ExampleZNF420_control_pos.wig`
- Scramble: `ExampleZNF420_scramble_pos.wig`
- Top1A:    `ExampleZNF420_top1A_pos.wig`
- Top1B:    `ExampleZNF420_top1B_pos.wig`

Create a text file using whatever text editor you want (recommended: nano, vim, for mac: textedit, textwrangler) and put all 4 file names, one file per row. Example is `FILES.txt`

> ExampleZNF420_control_pos.wig
> ExampleZNF420_scramble_pos.wig
> ExampleZNF420_top1A_pos.wig
> ExampleZNF420_top1B_pos.wig

Then run Pipeline.pl on the tet file, for example:

`./Pipeline.pl FILES.txt`

This will produce 1 peak file per sample and a combined peak file `output.peak`. For example, the above will produce:

> 1. ExampleZNF420_control_pos.peak
> 2. ExampleZNF420_scramble_pos.peak
> 3. ExampleZNF420_top1A_pos.peak
> 4. ExampleZNF420_top1B_pos.peak
> 5. output.PEAK
