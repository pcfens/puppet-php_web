require 'spec_helper'

describe 'php_web', :type => 'class' do
  context "On a Debian based OS" do
    let :facts do
      {
        :osfamily => 'Debian'
      }
    end

    context "Without a webserver specified" do
      # Apache things
      it { should contain_class('php_web::apache::package') }
      it { should contain_class('php_web::apache::config') }
      it { should contain_class('php_web::apache::service') }
      it { should contain_package('apache2') }
      it { should contain_service('apache2') }
      it { should contain_package('libapache2-mod-fastcgi') }
 
      # PHP things
      it { should contain_class('php_web::php::package') }
      it { should contain_class('php_web::php::config') }
      it { should contain_class('php_web::php::service') }
      it { should contain_package('php5-fpm') }
      it { should contain_service('php5-fpm') }

      # Other misc. things
    end
    context "Web server set to nginx on a Debian based OS" do
      let :params do
        {
          :webserver => 'nginx'
        }
      end
      # nginx things
      it { should contain_class('php_web::nginx::package') }
      it { should contain_class('php_web::nginx::config') }
      it { should contain_class('php_web::nginx::service') }
      it { should contain_package('nginx') }
      it { should contain_service('nginx') }

      # PHP things
      it { should contain_class('php_web::php::package') }
      it { should contain_class('php_web::php::config') }
      it { should contain_class('php_web::php::service') }
      it { should contain_package('php5-fpm') }
      it { should contain_service('php5-fpm') }

    end
  end
end
