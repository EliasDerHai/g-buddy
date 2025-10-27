## On gleam

 -  minimalist, clear, concise, typesafe, genious
 
Compilation speed is amazing. Allows fast feedback loop. I guess I'm getting better at originazing state also? 
But it's still a bit confusing to have 'deep' business logic next to 'toasts' or 'tooltip' - yet other options (sub-components, pure ffi/js solutions) are worse than packing it all into one state. Similar to state modelling the msgs for lustre have to be modelled.

Still missing macros, traits, and unions a bit. I get the tradeoff, but sometimes it just hurts to hassle around with stuff that's a given in other languages. On the other hand side the minimalism of the language allows for focusing on what matters rather than on type insanity/ trait tetris and proc-macro magic - that might brake eventually. Json encode, decode is tedious but claude can do it pretty good - allowing to enjoy working with rich types while not having to hassle with a lot of the dumb tasks. Still I don't dare to add more tests yet, should probably wait till I have a better idea on what I actually want to go for... 


## On game mechancis

 - planned to add guns and different kinds of weapons - with different ammunition, maybe special attacks that consume more or less ammunition, different crit/hit-chance
 - what about breaking up 1v1 fights to 1vN ? maybe figure out some other bits first
 - how to integrate items into the game (consumables, weapons, defence-boost through bullet-proof vest etc. ?, how to unlock etc...)
 - what is the best reward for winning fights? - just money? how to calc reward? 
 - how to progress in job ? 


## On story progress

 - completely TBD at this point
 - should I go with my typical Storyline -> Chapter -> StoryNode -> Choice approach? How can I make story-building feasable, typesafe, but **extensible** 
 - maybe focus on other mechanics first instead of getting lost in text-writing/narrative tasks again...


