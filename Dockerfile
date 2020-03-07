from ubuntu


# Install the build packages
RUN apt-get update
RUN apt-get -y install wget unzip bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev openjdk-8-jdk

# Install the SDK
RUN wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
RUN unzip platform-tools-latest-linux.zip -d ~

# DON'T DO THIS... use ENV !!
# RUN echo '# add Android SDK platform tools to path \n if [ -d "$HOME/platform-tools" ] ; then\n    PATH="$HOME/platform-tools:$PATH" \nfi' >> ~/.profile
# RUN cat ~/.profile
# RUN bash -c 'source ~/.profile'

# Ooops forgot....
RUN apt-get -y install python

# Put the ~/bin directory in your path of execution
ENV PATH="/root/platform-tools:/root/bin:${PATH}" 
RUN set | grep PATH
RUN pwd && whoami && ls -ltr /root/

# Create the directories
RUN mkdir -p ~/bin
RUN mkdir -p ~/android/lineage

# Install the repo command and Download the source code
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
RUN chmod a+x ~/bin/repo

# Just for testing...
RUN apt-get -y install tree

# Initialize the LineageOS source repository
WORKDIR ~/android/lineage
RUN ls -ltr ~/android/lineage
RUN pwd
RUN repo init -u https://github.com/LineageOS/android.git -b lineage-15.1
RUN repo sync

# Prepare the device-specific code
WORKDIR ~/android/lineage
RUN bash -c 'source build/envsetup.sh'
RUN breakfast bullhead

# Extract proprietary blobs
WORKDIR ~/android/lineage/device/lge/bullhead 
RUN ./extract-files.sh
RUN ls -l  ~/android/lineage/vendor/lge

# Turn on caching to speed up build
ENV USE_CCACHE=1
RUN ccache -M 50G
ENV CCACHE_COMPRESS=1

# Configure jack
ENV ANDROID_JACK_VM_ARGS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx4G"

# Start the build - Not sure I'm in the right directory??
RUN croot
RUN brunch bullhead

# Did it work?
RUN tree .
WORKDIR $OUT
RUN ls -ltr