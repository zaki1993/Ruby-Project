# Lisp::Interpreter
Lisp interpreter implemented in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lisp-interpreter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lisp-interpreter

## Usage
booleans:

    #t; #t
    
    #f; #f
    
    (not #t); #f
    
    (equal? 5 5); #t
    
    (if (<= 2 3) 'TRUE 'FALSE); TRUE
    
numbers:
    
    (+ 1 2); 3
    
    (- 1 2); -1
    
    (* 1 2); 2
    
    (/ 1 2); 0.5
    
    (quotient 10 3); 3
    
    (remainder 10 3); 1
    
    (modulo 10 3); 1
    
    (numerator 5); 5
    
    (denominator 5); 1
    
    (abs -10); 10
    
    (add1 1); 2
    
    (sub1 1); 0
    
    (min 5 3 1 2 4); 1
    
    (max 5 3 1 2 4); 5
    
    (< 1 2); #t
    
    (<= 2 2); #t
    
    (> 1 2); #f
    
    (>= 2 2); #t
    
strings:
    
    (string-length "Hello world"); 11
    
    (substring "Hello world" 4); "o world"
    
    (string-upcase "sample"); "SAMPLE"
    
    (string-downcase "SAMPLE"); "sample"
    
    (string-contains? "Racket" "Rac"); #t
    
    (string->list "Sample"); (#\S #\a #\m #\p #\l #\e)
    
    (string-split "  foo bar  baz \r\n\t"); ("foo" "bar" "baz")
    
    (string? "str"); #t
    
    (string-replace "foo bar baz" "bar" "blah"); "foo blah baz"
    
    (string-prefix? "Racket" "Rac"); #t
    
    (string-sufix? "Racket" "cket"); #t
    
    (string-join '(1 2) "potato"); "1potato2"
    
list and pairs:
    
    (null? '()); #t
    
    (cons 1 2); (1 . 2)
    
    null; ()
    
    (list 1 "s"); (1 "s")
    
    (car (list #f 2 3 4)); #f
    
    (cdr (list #f 2 3 4)); (2 3 4)
    
    (cadr (list 1 2 3 4)); 2
    
    (cdar (list (list 1 2) 2 3 4)); (2)
    
    (list? (list 1 2)); #t
    
    (pair? (list 1 2)); #t
    
    (length (list 1 2 3)); 3
    
    (reverse (list 1 2 3)); (3 2 1)
    
    (remove 1 (list 1 2 3)); (2 3)
    
    (shuffle (list 1 2 3)); permutation of [1, 2, 3]
    
    (map (lambda (n)(+ 1 n)) '(1 2 3 4)); (2 3 4 5)
    
    (foldl cons '() '(1 2 3 4 5)); (5 4 3 2 1)
    
    (foldr cons '() '(1 2 3 4 5)); (1 2 3 4 5)
    
    (filter (lambda (x) (<= x 3)) '(1 2 3 4 5)); (1 2 3)
    
    (member 2 (list 1 2 3 4)); (2 3 4)
    
functions and procedures:
    
    (lambda (x) (* 2 x)); <#Closure>
    
    ((lambda (x) (* 2 x)) 5); 10
    
    (apply + '(1 2 3)); 6
    
    ((compose fn1 fn2) val); (fn1 (fn2 val))

    (compose fn1 fn2); #<Closure>

errors:

    (+ 1 2 #t); "Invalid data type, expected <number> got <boolean>"

    (string-length 123); "Invalid data type, expected <string> got <number>"

    (string-join "SAMPLE"); "Invalid data type, expected <list> got <string>"

    (substring "sample"); "Incorrect number of arguments, expected [2, 3] got 1"

    (x); "x is not a function"

    x; "Unbound symbol x"
    
other:
    
    (define x 5); 5

    (define x (lambda (x) (* 2 x))); <#Closure>
    
    (define (even? x) (if (equal? (remainder x 2) 0) #t #f)); <#Closure>

    (define map foldl); <Function foldl>
    
    (even? 4); #t
    
    (even? 3); #f
    
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/zaki1993/Ruby-Project/lisp-interpreter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Lisp::Interpreter project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/zaki1993/Ruby-Project/lisp-interpreter/blob/master/CODE_OF_CONDUCT.md).
