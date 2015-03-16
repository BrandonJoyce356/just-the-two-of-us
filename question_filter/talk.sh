#!/bin/bash
clear

echo "colorscheme github" >> ~/.vimrc

vim version_1.rb
vimdiff version_1.rb version_2.rb
vimdiff version_2.rb version_3.rb
vimdiff version_3.rb version_4.rb
vimdiff version_4.rb version_5.rb
vimdiff version_5.rb version_6.rb
vimdiff version_6.rb version_7.rb
vimdiff version_7.rb version_8.rb
vimdiff version_8.rb version_9.rb
vimdiff version_1.rb verison_9.rb
