## An eCommerce Experiment with Elixir, Phoenix and OTP

I've been [writing a blog series](http://rob.conery.io/category/redfour) about creating an eCommerce store with Elixir. I had a few stumbles along the way but quickly became obsessed, so unfortunately stopped blogging about it.

Anyway - here is the working version of that effort. It's coming together - but I still have a ton to do. For instance I'm not convinced I want to keep Phoenix as I don't think I need all that it provides (Plug is a dandy abstraction). I'm not focused on UI at the moment (Bootstrap ... hmmm) which you'll notice when it starts up.

Speaking of...

## Installing

You'll need a database (Postgres) called `redfour`:

```sh
createdb redfour
```

Update the config files in the web app to use your connection. Next you'll need a Stripe key for `stripity-stripe`; put that in `/config/dev.secret.exs` so you can make charges.

Start it up in the `/web` directory with `mix phoenix.server`.
