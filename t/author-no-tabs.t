
BEGIN {
  unless ($ENV{AUTHOR_TESTING}) {
    require Test::More;
    Test::More::plan(skip_all => 'these tests are for testing by the author');
  }
}

use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::NoTabs 0.09

use Test::More 0.88;
use Test::NoTabs;

my @files = (
    'lib/MaxMind/DB/Reader/XS.pm',
    't/MaxMind/DB/Reader-broken-databases.t',
    't/MaxMind/DB/Reader-decoder.t',
    't/MaxMind/DB/Reader-no-ipv4-search-tree.t',
    't/MaxMind/DB/Reader.t',
    't/author-leak-check.t',
    't/author-no-tabs.t',
    't/author-pod-spell.t',
    't/lib/Test/MaxMind/DB/Reader.pm',
    't/release-cpan-changes.t',
    't/release-eol.t',
    't/release-pod-linkcheck.t',
    't/release-pod-no404s.t',
    't/release-pod-syntax.t',
    't/xs-only.t'
);

notabs_ok($_) foreach @files;
done_testing;
