#!/bin/bash
clear
echo 'OpenGl tutorial for Ubuntu Linux, Arch Linux, Void Linux'
echo
echo 'I came accross a very good OpenGl tutorial from Etay Meiri: https://ogldev.org/'
echo 'This file makes the tutorial compatible to your Linux version. I have many Nix packages installed on my system and I hope this script includes everything for plain Distro users.'
echo 'Due to my old graphics card I get errors at tutorial 50... using vulkan. Ubuntu includes vulkan header files, in Void they are installed by this script. Arch has a corrupt vulkan-headers package right now, install it manually if required. In Ubuntu you might want to use the original install script instead, but the by this script generated tutorial-start.sh files might help.'
echo 'Please edit this file as you whish before running. Start this file with bash install_ogldev.org.sh to avoid problems at least in Void Linux.'
echo 'A package manager update is recommended before running this script, i.e. apt update, pacman -Syu, xbps-install -Su'
echo
printf "To start a compiled tutorial execute this command: "
printf "\e[31m" #RED
echo 'bash tutorial-start.sh'
printf "\e[30m" #Black
printf "\e[0m" #STOP
echo 'This temporarily sets MESA_GL_VERSION_OVERRIDE=3.3 and MESA_GLSL_VERSION_OVERRIDE=330'
echo
#echo "Let the script install glxinfo if you do not know your glx version. It will be printed on screen while installing."
#echo
#echo "Insert your glx version into this script at these lines: "
#echo "export MESA_GL_VERSION_OVERRIDE=3.3 # or enter the highest value from previous glxinfo"
#echo "export MESA_GLSL_VERSION_OVERRIDE=330"
#echo "Version 330 is required by this tutorial."
#echo "This export... change is only temporary."
#echo "To make it permanent:"
#echo "You can put those lines with your glx version to /etc/environment:"
#echo "MESA_GL_VERSION_OVERRIDE=3.3"
#echo "MESA_GLSL_VERSION_OVERRIDE=330"
#echo "Or put the following two lines with your glx version i.e. into your .xinitrc:"
#echo "export MESA_GL_VERSION_OVERRIDE=3.3" # or enter the highest value from previous glxinfo
#echo "export MESA_GLSL_VERSION_OVERRIDE=330"
#echo 
read -p 'Hit enter to install or CTRL-C to abort: ' INPT

#read -p 'Delete the old ./ogldev-source (y/N): ' INPT
#[ "$INPT" = "y" ] && echo "rm -rf ogldev-source"
#[ "$INPT" = "y" ] && rm -rf ogldev-source
#[ "$INPT" = "y" ] && echo "rm -f ogldev-source.zip"
#[ "$INPT" = "y" ] && rm -f ogldev-source.zip
[ !  -e ogldev-source ] && echo 'git clone https://github.com/emeiri/ogldev.git ogldev-source'
[ !  -e ogldev-source ] && git clone https://github.com/emeiri/ogldev.git ogldev-source
echo 'rm -rf ogldev-source/.git'
rm -rf ogldev-source/.git
echo 'rm -rf ogldev-source/web'
rm -rf ogldev-source/web
echo 'cp InstallScripts/install_ogldev.org_void.sh ./ogldev-source'
cp install_ogldev.org.sh ./ogldev-source

echo 'copy tutorial-start.sh to all ./ogldev-source/tutorial??/'
echo '#!/bin/bash' > tutorial-start.sh
echo 'export MESA_GL_VERSION_OVERRIDE=3.3' >> tutorial-start.sh
echo 'export MESA_GLSL_VERSION_OVERRIDE=330' >> tutorial-start.sh
echo './tutorial?? &' >> tutorial-start.sh
find ./ogldev-source/tutorial?? -maxdepth 0 -type d -exec cp tutorial-start.sh {} \;
rm tutorial-start.sh

cd ogldev-source
#echo "zip -r ogldev-source ogldev-source"
#zip -r ogldev-source ogldev-source
if grep -q -wi archlinux /proc/version; then
   echo 'Setting up OGLDEV for Arch Linux' && 	sudo pacman -S --needed make gcc glew freeglut assimp imagemagick glfw-x11 mesa-demos #vulkan-headers # mesa-demos for glxinfo to check your glx version
fi 
if grep -q -wi voidlinux /proc/version; then
   echo 'Setting up OGLDEV for Void Linux' && 	sudo xbps-install make gcc glew-devel libfreeglut-devel assimp libassimp-devel ImageMagick libmagick-devel pkg-config glfw-devel glxinfo Vulkan-Headers
fi 
if grep -q -wi nixoslinux /proc/version; then
   echo 'Setting up  OGLDEV for Nixos Linux' && echo 'not implemented' && break
fi 
if grep -wi Ubuntu /proc/version; then
   echo 'Setting up  OGLDEV for Ubuntu Linux' && sudo apt install g++ make freeglut3-dev libglew-dev libglew2.1 imagemagick libmagick++-dev libassimp-dev libglfw3 libglfw3-dev mesa-utils
fi 
#echo "MESA_GL_VERSION_OVERRIDE=3.3" >> /etc/environment # or enter the highest value from previous glxinfo
#echo "MESA_GLSL_VERSION_OVERRIDE=330" >> /etc/environment

#echo "export MESA_GL_VERSION_OVERRIDE=3.3" >> ~/.bashrc # or enter the highest value from previous glxinfo
#echo "export MESA_GLSL_VERSION_OVERRIDE=330" >> ~/.bashrc
echo
echo '*Testing and overriding your GLX version:'
echo
echo '*GLXINFO before temporary overriding:'
#nixGLIntel glxinfo | grep 'shading language version string' # for nix users under Arch, install nixGLIntel from AUR and install glxinfo under your bootstrapped Arch with nix-env -iA glxinfo
glxinfo | grep 'shading language version string'
echo
export MESA_GL_VERSION_OVERRIDE=3.3 # or enter the highest value from previous glxinfo
export MESA_GLSL_VERSION_OVERRIDE=330
echo '*GLXINFO after temporary overriding:'
glxinfo | grep 'shading language version string'
#nixGLIntel glxinfo | grep 'shading language version string' # for nix users under Arch, install nixGLIntel from AUR
echo
echo 'Check your glx version before change and after change in the above. Make adjustments in this script and in tutorial-start.sh in each tutorial if desired. Version MESA_GLSL_VERSION_OVERRIDE=330 is required by this tutorial. This default value should work, but is not optimal for other graphical applications.'
echo
echo
if ! grep -wi Ubuntu /proc/version; then
     echo '*Modifying ./tutorial*/build.sh'
     echo 'Replacing ImageMagick++ with ImageMagick'
     sed -i 's/ImageMagick++/ImageMagick/g' ./tutorial*/build.sh
     echo 'Prepending `Magick++-config --cxxflags --cppflags` to compile command'
     sed -i 's/$CC tutorial/$CC `Magick++-config --cxxflags --cppflags` tutorial/g' ./tutorial*/build.sh
     echo 'Appending `Magick++-config --ldflags --libs` to compile command'
     sed -i '/tutorial.. `/!s/-o tutorial../& `Magick++-config --ldflags --libs`/g' ./tutorial*/build.sh
fi

echo
echo '*Modifying ./Include/ogldev_texture.h'
ImageMagickVersion=$(convert --version | awk '/Version: ImageMagick/{printf("%.1s"), $3}')
echo "Installed ImageMagick Version: $ImageMagickVersion"
echo 'replacing ImageMagick-8 -> ImageMagick-'$ImageMagickVersion #for future ImageMagick Versions
sed -i "s/ImageMagick-8/ImageMagick-$ImageMagickVersion/g" ./Include/ogldev_texture.h #for future ImageMagick Versions
echo 'replacing ImageMagick-7 -> ImageMagick-'$ImageMagickVersion #for future ImageMagick Versions
sed -i "s/ImageMagick-7/ImageMagick-$ImageMagickVersion/g" ./Include/ogldev_texture.h #for future ImageMagick Versions
echo 'replacing ImageMagick-6 -> ImageMagick-'$ImageMagickVersion
sed -i "s/ImageMagick-6/ImageMagick-$ImageMagickVersion/g" ./Include/ogldev_texture.h
echo
echo '*Modifying ./tutorial*/tutorial*.cpp'
echo 'Changing ogldev include files to local path'
sed -i '/Include/!s/#include "ogldev/#include "..\/Include\/ogldev/g' ./tutorial*/tutorial*.cpp #when line does not contain Include and contains #include "ogldev then insert #include "../Include/olgdev
echo '*Modifying ./Include/*.h'
echo 'Changing ogldev include files to local path'
sed -i '/Include/!s/#include "ogldev/#include "..\/Include\/ogldev/g' ./Include/*.h #when line does not contain Include and contains #include "olgdev then insert #include "../Include/olgdev
echo '*Modifying ./Common/*.cpp'
echo 'Changing ogldev include files to local path'
sed -i '/Include/!s/#include "ogldev/#include "..\/Include\/ogldev/g' ./Common/*.cpp #when line does not contain Include and contains #include "olgdev then insert #include "../Include/olgdev
printf "\e[32m"  # GREEN
echo '++++++++++++++++++++++++++++++Installation finished+++++++++++++++++++++++++++++++++++++++++'
printf "\e[30m" #Black
printf "\e[0m" #STOP
echo 'Test Build:'
echo
echo 'building tutorial16'
printf "\e[31m" #RED
echo '(wait 1 minute)'
printf "\e[30m" #Black
printf "\e[0m" #STOP
echo
echo 'In case no graphic window pops up after about a minute, check your Graphics card with glxinfo like explained above or try tutorial01 - tutorial15'
cd tutorial16
bash build.sh
echo
printf "\e[31m" #RED
echo 'executing tutorial-start.sh'
bash tutorial-start.sh &
printf "\e[30m" #Black
printf "\e[0m" #STOP
cd ..
echo
echo 'Watch his videos on youtube, User OGLDEV'
echo 'OpenGL For Beginners - Tutorial #1'
echo 'https://www.youtube.com/watch?v=DYuLHRsvZwk'
echo
echo '*******************************************************************************************'
echo 'Building 54 tutorials'
echo 'Hit CTRL-C to abort build_all.sh'
bash build_all.sh
echo 'Have fun.'
#sed ':a;N;$!ba;s/\n/ /g' foo | sed '{/::=BEGIN/{s/.*/1/; b next}; s/.*/0/; :next}'


