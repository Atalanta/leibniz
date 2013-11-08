# Things I'd like this tool to have
## in no particular order

### Jenkins

Or some other other CI workflow. At present we have a pretty slick Continuous Deployment pipeline for our code. It would be great if we could run our infrastructure code through the same sort of system, because at the moment, although we have tools like Etsy's [knife-spork](https://github.com/jonlives/knife-spork) to guard against idiocy, it's basically gated by me. Fallible, error-prone me.

I know Zach mentioned something about a [Jenkins workflow](https://github.com/Atalanta/cucumber-chef/issues/101) a while ago, but I never heard anything more.

### Test configuration per-project

[I mooted this back in April](https://github.com/Atalanta/cucumber-chef/pull/117) but then I went on holiday and kind of forgot about it. The somewhat lashed-together solution I came up with there looks a bit clunky now, but I think the idea still holds. Right now, I'm having to keep several different Labfiles around and symlink the correct one each time.


### Looser coupling of moving parts

Here's the thing: the most complex project I'm currently managing with cuke-chef has 5 different types of node. In order to test things like Chef-search correctly, I need to spin up one of each from the Labfile, which incurs a huge first-run penalty. Subsequent runs are better, but still incredibly time-consuming as it seems to provision all the nodes on each run (which is not unreasonable, I guess).

Maybe there are already clever things I could with mocking and so on but I've never really looked into that. But whatever, being able to exercise only the required node(s) on a given test run (without commenting-out whole blocks from the Labfile, which is my current anti-pattern) would be splendid.

### Full-stack testing

Right now, the way I'm using cuke-chef isn't at all BDD. My steps say things like

```
Scenario: www vhost is correct
    * file "/var/www/www/current/vhost" should contain
  """
  upstream www {
    server 127.0.0.1:3020;
  }

```

whereas what I *should* care about would be more like

```
  Scenario: Home page
    Given I am on "the home page"
    Then I should see "All work and no play makes Jack a dull boy"
```

Now of course this sort of stuff is tested in the apps themselves so maybe I'm looking at this from the wrong end, or maybe others are already doing this with cuke-chef and and I'm just Doing It Wrong.

But this, combined with the *Test configuration per-project* idea from above, would maybe let us test the entire stack from base OS to working app, which has a certain appeal.
