
This is not a document where I keep todos like todo-tasks, this is the document where I document the thoughts.

###Dataflow...
Stores (from flux/react) will be used as the name for "statekeeping/handling"components.

Dataflow should follow the ideas of unidirectional dataflow, and also make sure that the developer can easily follow the dataflow from stores to views. Especially if one action would engage mutiple stores in a certain order, where one store needs to wait for another.  Is a central dispatcher the best way?
Should the event-queueing/waiting/handling be handled in controller-views? Should it be handled by the dispatcher or each separate store.
The goal with every part of the application, both stores and views should be easily inserted and removed without breaking anything of the application. If a view has a loose dependency on a store that is for some reason removed the view should behave predictably anyways. When a store that can respond to action events from the view, the view should just come alive again.
Flux pattern is good, but why does stores need to listen to everything?

###Eventnaming.
Some convention for eventnaming is needed, and it should be as close to dom eventnames as possible. Difference would be that the these events always include a payload.

Viewcomponents and store components.

##Application structure.
Try to follow the pattern that facebook uses with its react and flux pattern, create listening/controller-views, and build those up of smaller components. The "listening/eventemitting/controller-view" would be the one that listens to the changes of its smaller parts and communicates with the dispatcher. This "communicator-tag" would probably pretty often be the actual page-tag. 
