Backend implementation using Vapor, a server-side Swift webt framework. Uses MySQL as the underlying database. Hosted on DigitalOcean.

Use HomeBrew to install needed packages. If you don't have HomeBrew follow their instructions.
https://brew.sh/

brew install mysql
brew install cmysql
brew tap vapor/homebrew-tap
brew update
brew install vapor

cd into root directory of repo

vapor build
vapor run serve




