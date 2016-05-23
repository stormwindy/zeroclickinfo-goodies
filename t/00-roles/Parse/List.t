#!/usr/bin/env perl

use strict;
use warnings;

use Test::Most;

# Just so we don't have to type cmp_deeply over and over...
sub t { cmp_deeply(@_) }

sub parse_test {
    my ($to_parse, $expected) = @_;
    my $parsed = ListTester::parse_list($to_parse);
    t($parsed, $expected, "parse $to_parse");
}

sub parse_test_no {
    my ($to_parse, %options) = @_;
    my $parsed = ListTester::parse_list($to_parse, %options);
    is($parsed, undef, "parse $to_parse");
}

subtest initialization => sub {
    { package ListTester; use Moo; with 'DDG::GoodieRole::Parse::List'; 1; }

    new_ok('ListTester', [], 'Applied to a class');
};

subtest parse_list => sub {
    subtest 'varying brackets' => sub {
        my %brackets = (
            '[' => ']',
            '{' => '}',
            '(' => ')',
            ''  => '',
        );
        while (my ($open, $close) = each %brackets) {
            my $test_list = "${open}1, 2, 3$close";
            my $expected  = [1, 2, 3];
            subtest "brackets: $open$close" => sub {
                parse_test($test_list, $expected);
            };
        }
    };

    subtest 'number of items' => sub {
        my %tcs = (
            0 => '[]',
            1 => '[1]',
            2 => '[1, 2]',
            4 => '[1, 2, 3, 4]',
        );
        while (my ($amount, $tstring) = each %tcs) {
            subtest "$amount items" => sub {
                parse_test($tstring, arraylength($amount));
            };
        }
    };

    subtest 'varying separator' => sub {
        my @tcs = (
            '1,2,3,4',
            '1, 2, 3, 4',
            '1, 2, 3, and 4',
            '1 and 2 and 3 and 4',
            '1 and 2 and 3, and 4',
        );
        my $expected = [1, 2, 3, 4];
        foreach my $tc (@tcs) {
            parse_test($tc, $expected);
        }
    };

    subtest 'invalid strings' => sub {
        my @tcs = (
            '',
        );
        foreach my $tc (@tcs) {
            parse_test_no($tc);
        }
    };
};

done_testing;

1;
