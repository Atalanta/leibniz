# Things I'd like this tool to have
## in no particular order

### Jenkins

Or some other other CI workflow. At present we have a pretty slick Continuous Deployment pipeline for our code. It would be great if we could run our infrastructure code through the same sort of system, because at the moment, although we have tools like Etsy's [knife-spork](https://github.com/jonlives/knife-spork) to guard against idiocy, it's basically gated by me. Fallible, error-prone me.

I know Zach mentioned something about a [Jenkins workflow](https://github.com/Atalanta/cucumber-chef/issues/101) a while ago, but I never heard anything more.

#### Current Status

- A project could be checked out and cucumber run by Jenkins or Travis
- However at present Leibniz only knows how to build machines via TK with the Vagrant driver
- This would mean we couldn't run it on Travis or on a 'cloud' Jenkins box; ie the Jenkins box would need to run Vagrant
  - that said I'm not sure whether Vagrant itself would be able to use the EC2 'provider'?

#### Next Steps

- On a physical box, prove that we can run a Leibniz job from Jenkins
- Try to get Leibniz to with TK to with the EC2 driver (or LXC / Docker)

### Test configuration per-project

[I mooted this back in April](https://github.com/Atalanta/cucumber-chef/pull/117) but then I went on holiday and kind of forgot about it. The somewhat lashed-together solution I came up with there looks a bit clunky now, but I think the idea still holds. Right now, I'm having to keep several different Labfiles around and symlink the correct one each time.

#### Current Status

- Leibniz simply provides an interface to Test Kitchen, and passes over a run list.
- This means we can have features / steps per project or per cookbook - whatever works

#### Next Steps

- Demonstrate that this can work with Librarian?


### Looser coupling of moving parts

Here's the thing: the most complex project I'm currently managing with cuke-chef has 5 different types of node. In order to test things like Chef-search correctly, I need to spin up one of each from the Labfile, which incurs a huge first-run penalty. Subsequent runs are better, but still incredibly time-consuming as it seems to provision all the nodes on each run (which is not unreasonable, I guess).

Maybe there are already clever things I could with mocking and so on but I've never really looked into that. But whatever, being able to exercise only the required node(s) on a given test run (without commenting-out whole blocks from the Labfile, which is my current anti-pattern) would be splendid.

#### Current Status

- Acceptance tests shouldn't mock - we want to exercise all the pieces
- TK allows us to use Chef Zero - which gives us an in memory Chef server, including search, which is really really quick
- At lower levels (chefspec) we can stub the search and return data

#### Next Steps

- Demonstrate (and document) how to make Leibniz use the chef-zero provisioner

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

#### Current Status

- The lower-level 'vhost is correct' steps should be run post-converge on the node under test using TK + whatever you want to write tests with (I recommend serverspec)
- The high-level BDD-style acceptance tests (the homepage does what it should) is precisely what Leibniz & Cucumber are for
