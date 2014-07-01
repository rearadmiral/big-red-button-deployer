package "ruby-dev"
package "libusb-1.0-0-dev"

gem_package "bundler"

bash "bundle" do
  code "cd /vagrant && bundle install"
end
