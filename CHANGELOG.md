# Changelog

## 2.1.1 2017-08-26

- Add support for SSL when testing for redirects

## 2.1.0 2017-03-14

- Add another variable to nexus.properties.erb to configure nexus-args

## 2.0.1 2017-03-08

- Update uninstall so it doesn't delete the entire contents of /opt

## 2.0.0 2016-12-17

- Refactor for 3.1

## 1.0.0 2016-11-14

- Fix #17 nexus 3.1.0 config file location changed

## 0.9.2 2016-10-14

- Fix #16 Fixes version regex that matches host-name when containing digits 

## 0.9.1 2016-09-06

- Fix #13 Wrong home folder

## 0.9.0 2016-09-05

- Make application-host configurable

## 0.8.0 2016-08-20

- Fix #11 Do not set user home to path dir

## 0.7.0 2016-08-19

- Replace root attribute with path
- Fix #10 nexus3_api ignore_failure attribute defaults to false 

## 0.6.0 2016-08-15

- Fix #9 Why_run/converge_by causes notifies to fire when no changes

## 0.5.0 2016-08-13

- Resolve #5 Add support for Windows configuration

## 0.4.0 2016-08-11

- Wait for Nexus Rest API endpoint to respond
- Replace vmoptions attribute with template

## 0.3.0 2016-08-08

- Fix #4 Support Windows install
- Fix #6 Change install directory to closely match docker image

## 0.2.1 2016-08-01

- Fix #2 Custom url issue

## 0.2.0 2016-07-29

- Add REST API

## 0.1.1 2016-07-28

- Fix #1 FileNotFoundException due to Chef searching for template files in a wrapper cookbook

## 0.1.0 2016-07-26

- Initial beta release
