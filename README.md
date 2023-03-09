# Who Wants to Be a Millionaire (WWBM)

The famous TV game Who Wants to Be a Millionaire? on Ruby on Rails from the [Goodprogrammer](https://goodprogrammer.ru/rails) course.



The application was created on Ruby 3.1.2 and Ruby on Rails 7.0.4

### Required to run the application

`Ruby` installed. `SQLite3` is used for data storage in development.
`

Next, you need to run the following commands:

```
$ bundle
$ bundle exec rake db:create
$ bundle exec rake db:migrate
$ bundle exec rake db:seed
```

Run app:

```
$ rails s
```

And visit `http://localhost:3000`.
