StylightTask
============
This is a very basic implementation of the task you gave me, there are many more
things that could be implemented.
Due to the way I implemented this, there is no possibility to make the same API call twice because
everything is persisted in CoreData and is loaded from there if needed.
This is the reason why I did not implement a restriction for only making the same API call once in 15 minutes.
This would only be necessary if the app would have a refresh option or something.
One could implement such a restriction by hashing and saving the URL of the API call with a timestamp and check
if it was already called in the last 15 min.

I am looking forward to meet you guys, and hopefully be part of your team.
best regards
Bernhard
