## An eCommerce Experiment with Elixir and OTP

Peach is an API-only eCommerce storefront. For now there is no templating, no HTML, etc - it's just an API. I started out with Phoenix and decided that it didn't quite fit what I wanted so I switch over to [Maru](https://github.com/falood/maru) - a small, Grape-inspired API front end. It fits perfectly.

I also was thinking about [Trot](https://github.com/hexedpackets/trot) but decided that I wanted to leave the CMS/HTML stuff to a framework or application that is very good at it; Peach can be just one part of the puzzle.

I've been [writing a blog series](http://rob.conery.io/category/redfour) about creating an eCommerce store with Elixir and I plan to continue on, as this is an application that I'll need very soon. You're welcome to help :).


## Installing

You'll need a database (Postgres) called `redfour`:

```sh
createdb redfour
```

Update the config files in the web app to use your connection. Next you'll need a Stripe key for `stripity-stripe`; put that in `/config/dev.secret.exs` so you can make charges.

You can start everything up with:

```
mix peach.start
```

## Tests

I have the core catalog and cart stuff started out, but have changed course enough times that I had to rip the bulk of the tests out as I mused on architecture. I need more tests, obviously, especially for the API which (according to the docs) is pretty simple to do.

You can run the tests (once you have the database created) using `mix test --trace`.
