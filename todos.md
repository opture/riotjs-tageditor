
This is not a document where I keep todos like todo-tasks, this is the document where I document the thoughts.

###Dataflow...
Stores (from flux/react) will be used as the name for "statekeeping/handling"components.

Dataflow should follow the ideas of unidirectional dataflow, and also make sure that the developer can easily follow the dataflow from stores to views. Especially if one action would engage mutiple stores in a certain order, where one store needs to wait for another. How is that best silver without a central dispatcher? Is a central dispatcher the best way?
Flux pattern is good, but why does stores need to listen to everything?

###Eventnaming.
Some convention for eventnaming is needed, and it should be as close to dom eventnames as possible. Difference would be that the these events always include a payload.

Viewcomponents and store components.

##Application structure.
Try to follow the pattern that facebook uses with its react and flux pattern, create listening/controller-views, and build those up of smaller components. The "listening/eventemitting/controller-view" would be the one that listens to the changes of its smaller parts and communicates with the dispatcher. This "communicator-tag" would probably pretty often be the actual page-tag. 
