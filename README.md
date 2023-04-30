# Trashy

Project setup caveats:
- Need a Sendgrid api key: https://app.sendgrid.com/ and [API instructions here](https://hexdocs.pm/swoosh/Swoosh.Adapters.Sendgrid.html)
- Set the api key in the `SENDGRID_API_KEY` environment variable 

Admin tasks:
- Set organizers: After a user has registered, set them to be an organizer like `UPDATE users SET is_organizer=True WHERE email='eric.munsing@gmail.com';`
- Create new cleanups: `INSERT INTO cleanups (location, neighborhood, inserted_at, updated_at) VALUES ('Manny''s', 'Northern Mission', '2023-04-29 00:06:46', '2023-04-29 00:06:46');`
- Associate an organizer with a cleanup: 
`INSERT INTO cleanup_organizers (cleanup_id, organizer_id, inserted_at, updated_at) VALUES (2, 1, '2023-04-29 00:06:46', '2023-04-29 00:06:46');`

# Phoenix Framework boilerplate

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
