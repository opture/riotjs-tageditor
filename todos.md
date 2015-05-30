###Dataflow...
Stores (from flux/react) will be used as the name for "statekeeping/handling"components.

Dataflow should follow the ideas of unidirectional dataflow, and also make sure that the developer can easily follow the dataflow from stores to views. Especially if one action would engage mutiple stores in a certain order, where one store needs to wait for another. How is that best silver without a central dispatcher? Is a central dispatcher the best way?
Flux pattern is good, but why does stores need to listen to everything?

###Eventnaming.
Some convention for eventnaming is needed, and it should be as close to dom eventnames as possible. Difference would be that the these events always include a payload.

Viewcomponents and store components.

