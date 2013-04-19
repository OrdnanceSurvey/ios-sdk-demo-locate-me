Description
---

A demo app using the ordnancesurvey-ios-sdk to display the user's location to make use of location services. Also includes an example of search functionality, allowing offline searches from Ordnance Survey's 50k Gazetteer, OS Locator and Code-Point Open datasets.



![ScreenShot](https://github.com/OrdnanceSurvey/ios-sdk-demo-locate-me/raw/master/screenshot.png "Screenshot of demo app")


Getting started
---

#### Requirements

This project requires the following points are met:

- Minimum iOS version: 6.0.1
- Xcode version: 4.5.2
- iOS Openspace SDK version: TBC


### Register for an API Key

Developers who wish to use the online services will need to register for an API key in order to authenticate requests.

When registering for an API Key we need to know a couple of items:

* Bundle Identifier of the application using the API key

Let us know the Bundle Identifier of the Xcode project in which you will be using the API. This is available and configurable when creating an Xcode project or from project settings or `Info.plist`


* Apple App ID to be associated with this application

This ID is the unique Apple ID generated in iTunes Connect when creating a new iOS application for the Apple AppStore



### Registration Process

If you do not own a re-use data licence you can register for an API key to access [OS OpenSpace Pro] (https://www.ordnancesurvey.co.uk/oswebsite/web-services/os-openspace/pro/index.html) under a 90 day trial or a commercial re-use licence. 

If you own a data licence, for example, you are a member of the PSMA, you can register for an API key to access [OSOnDemand WMTS] (http://www.ordnancesurvey.co.uk/oswebsite/web-services/os-ondemand/pricing.html).

#### Download project

Copy the project to your local machine, eg:

```bash
git clone https://github.com/OrdnanceSurvey/ios-sdk-demo-locate-me.git
```

#### Download ordnancesurvey-ios-sdk

- Download the latest ordnancesurvey-ios-sdk framework from [www.ordnancesurvey.co.uk](https://www.ordnancesurvey.co.uk/oswebsite/web-services/os-openspace/pro/ios-sdk.html)
 - Unzip the SDK into the `StaticFrameworks` directory at the root of the project
 
<pre>
$SRCROOT/StaticFrameworks
</pre>
 
#### Build Ordnance Survey POI database

This project is configured to use the offline points of interest database containing the following Open datasets:

- 1:50K Gazetteer
- OS Locator
- Codepoint Open datasets

Please follow the guide [here](https://github.com/OrdnanceSurvey/ordnancesurvey-ios-sdk#poi-database) to build the POI database.

Copy the file into the `Resources` directory at the root of the project:
<pre>
 $SRCROOT/Resources
</pre>

The file is referenced in the project settings and defined in the demo application here:

```objective-c
//In MapViewController.m

static NSString *const kOSPoiDBFilename = @"db.ospoi";

```

#### Update demo app with your API Key and Bundle Identifier details

Copy and paste the API Key into the demo app

Update the Bundle Identifier associated with the API Key

```objective-c
//In MapViewController.m

static NSString *const kOSApiKey = @"YOUR_KEY_HERE";
static BOOL const kOSIsPro = YES;

```

#### Build and run

Project can now be built and run - if you're using the simulator don't forget to mock your location to London.


Questions and Issues
-------

If you have any questions or issues with the ordnancesurvey-ios-sdk or this demo app then please email osopenspacepro@ordnancesurvey.co.uk


Licence
-------

The Ordnance Survey iOS SDK is protected by © Crown copyright – Ordnance
Survey 2013. It is subject to licensing terms granted by Ordnance Survey, the
national mapping agency of Great Britain.

The Ordnance Survey iOS SDK includes the Route-Me library. The Route-Me
library is copyright (c) 2008-2013, Route-Me Contributors All rights reserved
(subject to the BSD licence terms as follows):

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer. * Redistributions in binary
  form must reproduce the above copyright notice, this list of conditions and
  the following disclaimer in the documentation and/or other materials provided
  with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Route-Me depends on the Proj4 Library. [ http://trac.osgeo.org/proj/wiki/WikiStart ]
Proj4 is copyright (c) 2000, Frank
Warmerdam / Gerald Evenden Proj4 is subject to the MIT licence as follows:

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
