Redmine GC sync for [Mega Calendar Plugin](https://github.com/riccardonar/mega_calendar)
================

I'm not a ruby programmer, so i'm started from [Redmine GC Sync](https://github.com/MYchaieb/redmine_gc_sync)

================
## Installation
* Clone this repository into ```{REDMINE_ROOT}/plugins/```

	``` git clone https://github.com/riccardonar/mega_calendar_gc_sync.git ```

* Install dependencies and migrate database
	```console
	cd redmine/
	bundle install
	rake redmine:plugins:migrate RAILS_ENV=production
	```
* Restart your Redmine web server 
	``` service apache2 restart ```

## Plugin Configuration

Go to ``` Administration >  Plugins > Mega Calendar: Gc Sync plugin : Configure ``` and follow the steps. 

### Obtain a Client ID and Secret  
 1. Go to the [GOOGLE DEVELOPPERS CONSOLE](https://console.developers.google.com/).
 2. Select a project, or create a new one.
 3. In the sidebar on the left, expand APIs & auth. Next, click APIs. In the list of APIs, make sure the status is ON for the Calendar API
 4. In the sidebar on the left, select Credentials.
 5. In either case, you end up on the Credentials page and can create your project's credentials from here.
 6. If you haven't done so already, create your OAuth 2.0 credentials by clicking Create new Client ID under the OAuth heading. Next, look for your application's client ID and client secret in the relevant table.

### Find your calendar ID 
 1. Visit [Google Calendar](https://www.google.com/calendar/) in your web browser.
 2. In the calendar list on the left, click the down-arrow button next to the appropriate calendar, then select Calendar settings.
 3. In the Calendar Address section, locate the Calendar ID listed next to the XML, ICAL and HTML buttons.
 4. Copy the Calendar ID.

# Sync google calendar for users
 Create a custom filed to fill user google calendar address: go ```Administration > Custom Fields > add``` and set it as Text field
 For each user you can set the email address of his calendar

 After the configuration of the plugin, a filter part will appear :

 Set the custom field used for google calendar email and which Status you want to sync


## Tasks
Thera are some rake task:

 * **gc_sync_add** to run just one time to synchronize all issues and events that repect the filter rule you configured
 	* run this on the redmine root

	``` rake gc_sync_add:exec RAILS_ENV="production" ```
 
 * **gc_sync_del** to run just one time to delete all syncronized Issues and Events
 	* run this on the redmine root 

	``` rake gc_sync_del:exec RAILS_ENV="production" ```

 * **gc_sync_get** to run in cron to update date and time of previous syncronized Issues and Events from Google Calendar
 	* run this on the redmine root 

	``` rake gc_sync_get:exec RAILS_ENV="production" ```

## Uninstallation

	``` rake redmine:plugins:migrate NAME=mega_calendar_gc_sync VERSION=0 RAILS_ENV=production ```
