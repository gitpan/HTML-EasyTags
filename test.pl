# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..65\n"; }
END {print "not ok 1\n" unless $loaded;}
use HTML::EasyTags 1.03;
$loaded = 1;
print "ok 1\n";
use strict;

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

######################################################################
# Here are some utility methods:

my $test_num = 1;  # same as the first test, above

sub result {
	$test_num++;
	my ($worked, $detail) = @_;
	print "@{[$worked ? '' : 'not ']}ok $test_num $detail\n";
}

sub vis {
	my ($str) = @_;
	$str =~ s/\n/\\n/g;  # make newlines visible
	$str =~ s/\t/\\t/g;  # make tabs visible
	return( $str );
}

sub serialize {
	my ($input,$is_key) = @_;
	return( join( '', 
		ref($input) eq 'HASH' ? 
			( '{ ', ( map { 
				( serialize( $_, 1 ), serialize( $input->{$_} ) ) 
			} sort keys %{$input} ), '}, ' ) 
		: ref($input) eq 'ARRAY' ? 
			( '[ ', ( map { 
				( serialize( $_ ) ) 
			} @{$input} ), '], ' ) 
		: defined($input) ?
			"'$input'".($is_key ? ' => ' : ', ')
		: "undef".($is_key ? ' => ' : ', ')
	) );
}

######################################################################
# test new(), clone(), and property setting methods

{
	my $html1 = HTML::EasyTags->new();
	result( UNIVERSAL::isa( $html1, "HTML::EasyTags" ), "new() ret EasyTags obj" );
	result( UNIVERSAL::isa( $html1, "Class::ParamParser" ), "new() obj isa ParamParser" );

	my ($res1);

	my $html2 = HTML::EasyTags->new();
	$res1 = $html2->groups_by_default();
	result( $res1 == 0, "new() inits group prop to '$res1'" );
			
	$res1 = $html2->groups_by_default( 1 );
	result( $res1 == 1, "groups_by_default( 1 ) returns '$res1'" );
	
	my $html3 = $html2->clone();
	$res1 = $html3->groups_by_default();
	result( $res1 == 1, "clone() copies group prop as '$res1'" );
	
	$res1 = $html3->groups_by_default( 0 );
	result( $res1 == 0, "groups_by_default( 0 ) returns '$res1'" );
}

######################################################################
# test prologue_tag()

{
	my $html = new HTML::EasyTags();
	my ($does, $should);
	$does = $html->prologue_tag();
	$should = "\n<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\">";
	result( $does eq $should, "prologue_tag() ".
		"returns '".vis($does)."'" );
}

######################################################################
# test comment_tag()

{
	my $html = new HTML::EasyTags();
	my ($does, $should);

	$does = $html->comment_tag();
	$should = "\n<!--  -->";
	result( $does eq $should, "comment_tag() ".
		"returns '".vis($does)."'" );

	$does = $html->comment_tag( "hello" );
	$should = "\n<!-- hello -->";
	result( $does eq $should, "comment_tag( 'hello' ) ".
		"returns '".vis($does)."'" );

	$does = $html->comment_tag( ["hello", "world"] );
	$should = "\n<!-- \n\thello\n\tworld\n -->";
	result( $does eq $should, "comment_tag( ['hello','world'] ) ".
		"returns '".vis($does)."'" );
}

######################################################################
# test make_html_tag()

{
	my $html = new HTML::EasyTags();
	my ($does, $should);

	# try no args

	$does = $html->make_html_tag();
	$should = "\n<></>";
	result( $does eq $should, "make_html_tag() ".
		"returns '".vis($does)."'" );

	# try with tag name only

	$does = $html->make_html_tag( 'p' );
	$should = "\n<P></P>";
	result( $does eq $should, "make_html_tag( 'p' ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag( 'img' );
	$should = "\n<IMG>";
	result( $does eq $should, "make_html_tag( 'img' ) ".
		"returns '".vis($does)."'" );

	# try with tag name and visible text only

	$does = $html->make_html_tag( 'p', undef, 'hello' );
	$should = "\n<P>hello</P>";
	result( $does eq $should, "make_html_tag( 'p', undef, 'hello' ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag( 'img', undef, 'hello' );
	$should = "\n<IMG>hello";
	result( $does eq $should, "make_html_tag( 'img', undef, 'hello' ) ".
		"returns '".vis($does)."'" );

	# try with tag name, visible text, and part to make (4 types)

	$does = $html->make_html_tag( 'p', undef, 'hello', 'group' );
	$should = "\n<P>hello</P>";
	result( $does eq $should, "make_html_tag( 'p', undef, 'hello', 'group' ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag( 'img', undef, 'hello', 'group' );
	$should = "\n<IMG>hello";
	result( $does eq $should, "make_html_tag( 'img', undef, 'hello', 'group' ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag( 'p', undef, 'hello', 'pair' );
	$should = "\n<P>hello</P>";
	result( $does eq $should, "make_html_tag( 'p', undef, 'hello', 'pair' ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag( 'img', undef, 'hello', 'pair' );
	$should = "\n<IMG>hello</IMG>";
	result( $does eq $should, "make_html_tag( 'img', undef, 'hello', 'pair' ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag( 'p', undef, 'hello', 'start' );
	$should = "\n<P>hello";
	result( $does eq $should, "make_html_tag( 'p', undef, 'hello', 'start' ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag( 'img', undef, 'hello', 'start' );
	$should = "\n<IMG>hello";
	result( $does eq $should, "make_html_tag( 'img', undef, 'hello', 'start' ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag( 'p', undef, 'hello', 'end' );
	$should = "\n</P>";
	result( $does eq $should, "make_html_tag( 'p', undef, 'hello', 'end' ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag( 'img', undef, 'hello', 'end' );
	$should = "\n</IMG>";
	result( $does eq $should, "make_html_tag( 'img', undef, 'hello', 'end' ) ".
		"returns '".vis($does)."'" );

	# try with tag name and tag params only

	$does = $html->make_html_tag( 'input', {} );
	$should = "\n<INPUT>";
	result( $does eq $should, "make_html_tag( 'input', {} ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag( 'input', { type => 'radio' } );
	$should = "\n<INPUT TYPE=\"radio\">";
	result( $does eq $should, "make_html_tag( 'input', { type => 'radio' } ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag( 'input', { type => 'radio', 
		name => 'choice', size => 42, checked => 0 } );
	$should = "\n<INPUT TYPE=\"radio\" NAME=\"choice\" SIZE=\"42\">";
	result( $does eq $should, "make_html_tag( 'input', { type => 'radio', ".
		"name => 'choice', size => 42, checked => 0 } ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag( 'input', { type => 'radio', 
		name => 'choice', size => 42, checked => 1 } );
	$should = "\n<INPUT TYPE=\"radio\" NAME=\"choice\" CHECKED SIZE=\"42\">";
	result( $does eq $should, "make_html_tag( 'input', { type => 'radio', ".
		"name => 'choice', size => 42, checked => 1 } ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag( 'input', { type => 'radio', zb => 'xy' } );
	$should = "\n<INPUT TYPE=\"radio\" ZB=\"xy\">";
	result( $does eq $should, "make_html_tag( 'input', { type => 'radio', zb => 'xy' } ) ".
		"returns '".vis($does)."'" );

	# try with tag name, tag params, visible text

	$does = $html->make_html_tag( 'p', { class => 'Standard' }, 'hello' );
	$should = "\n<P CLASS=\"Standard\">hello</P>";
	result( $does eq $should, "make_html_tag( 'p', { class => 'Standard' }, 'hello' ) ".
		"returns '".vis($does)."'" );
}

######################################################################
# test make_html_tag_group()

{
	my $html = new HTML::EasyTags();
	my ($does, $should);

	# try no args

	$does = $html->make_html_tag_group();
	$should = "\n<></>";
	result( $does eq $should, "make_html_tag_group() ".
		"returns '".vis($does)."'" );

	# try with tag name only

	$does = $html->make_html_tag_group( 'p' );
	$should = "\n<P></P>";
	result( $does eq $should, "make_html_tag_group( 'p' ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag_group( 'img' );
	$should = "\n<IMG>";
	result( $does eq $should, "make_html_tag_group( 'img' ) ".
		"returns '".vis($does)."'" );

	# try with tag name and visible text only

	$does = $html->make_html_tag_group( 'p', undef, 'hello' );
	$should = "\n<P>hello</P>";
	result( $does eq $should, "make_html_tag_group( 'p', undef, 'hello' ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag_group( 'img', undef, 'hello' );
	$should = "\n<IMG>hello";
	result( $does eq $should, "make_html_tag_group( 'img', undef, 'hello' ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag_group( 'td', undef, ['hello', 'world'] );
	$should = "\n<TD>hello</TD>\n<TD>world</TD>";
	result( $does eq $should, "make_html_tag_group( 'td', undef, ['hello', 'world'] ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag_group( 'td', undef, [1..5] );
	$should = "\n<TD>1</TD>\n<TD>2</TD>\n<TD>3</TD>\n<TD>4</TD>\n<TD>5</TD>";
	result( $does eq $should, "make_html_tag_group( 'td', undef, [1..5] ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag_group( 'td', undef, [undef, undef] );
	$should = "\n<TD></TD>\n<TD></TD>";
	result( $does eq $should, "make_html_tag_group( 'td', undef, [undef, undef] ) ".
		"returns '".vis($does)."'" );

	# try with tag name and tag params only

	$does = $html->make_html_tag_group( 'input', {} );
	$should = "\n<INPUT>";
	result( $does eq $should, "make_html_tag_group( 'input', {} ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag_group( 'input', { type => 'radio' } );
	$should = "\n<INPUT TYPE=\"radio\">";
	result( $does eq $should, "make_html_tag_group( 'input', { type => 'radio' } ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag_group( 'input', { type => 'radio', 
		name => 'choice', size => 42, checked => 0 } );
	$should = "\n<INPUT TYPE=\"radio\" NAME=\"choice\" SIZE=\"42\">";
	result( $does eq $should, "make_html_tag_group( 'input', { type => 'radio', ".
		"name => 'choice', size => 42, checked => 0 } ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag_group( 'input', { type => 'radio', 
		name => 'choice', size => 42, checked => 1 } );
	$should = "\n<INPUT TYPE=\"radio\" NAME=\"choice\" CHECKED SIZE=\"42\">";
	result( $does eq $should, "make_html_tag_group( 'input', { type => 'radio', ".
		"name => 'choice', size => 42, checked => 1 } ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag_group( 'input', { type => 'radio', checked => [1,0,1,1,0] } );
	$should = "\n<INPUT TYPE=\"radio\" CHECKED>\n<INPUT TYPE=\"radio\">\n<INPUT TYPE=\"radio\" CHECKED>\n<INPUT TYPE=\"radio\" CHECKED>\n<INPUT TYPE=\"radio\">";
	result( $does eq $should, "make_html_tag_group( 'input', type => 'radio', checked => [1,0,1,1,0] } ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag_group( 'input', { type => 'radio', zb => 'xy' } );
	$should = "\n<INPUT TYPE=\"radio\" ZB=\"xy\">";
	result( $does eq $should, "make_html_tag_group( 'input', { type => 'radio', zb => 'xy' } ) ".
		"returns '".vis($does)."'" );

	# try with tag name, tag params, visible text

	$does = $html->make_html_tag_group( 'p', { class => 'Standard' }, 'hello' );
	$should = "\n<P CLASS=\"Standard\">hello</P>";
	result( $does eq $should, "make_html_tag_group( 'p', { class => 'Standard' }, 'hello' ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag_group( 'p', { class => 'Standard' }, ['hello','world'] );
	$should = "\n<P CLASS=\"Standard\">hello</P>\n<P CLASS=\"Standard\">world</P>";
	result( $does eq $should, "make_html_tag_group( 'p', { class => 'Standard' }, ['hello','world'] ) ".
		"returns '".vis($does)."'" );

	$does = $html->make_html_tag_group( 'p', { align => ['left','center','right'] }, ['hello','world'] );
	$should = "\n<P ALIGN=\"left\">hello</P>\n<P ALIGN=\"center\">world</P>\n<P ALIGN=\"right\">world</P>";
	result( $does eq $should, "make_html_tag_group( 'p', { align => ['left','center','right'] }, ['hello','world'] ) ".
		"returns '".vis($does)."'" );

	# try with force list
	
	$does = serialize( $html->make_html_tag_group( 'img', undef, 'hello', 1 ) );
	$should = serialize( [ "\n<IMG>hello" ] );
	result( $does eq $should, "make_html_tag_group( 'img', undef, 'hello', 1 ) ".
		"returns '".vis($does)."'" );

	$does = serialize( $html->make_html_tag_group( 'td', undef, ['hello', 'world'], 1 ) );
	$should = serialize( [ "\n<TD>hello</TD>", "\n<TD>world</TD>" ] );
	result( $does eq $should, "make_html_tag_group( 'td', undef, ['hello', 'world'], 1 ) ".
		"returns '".vis($does)."'" );
}

######################################################################
# test autoloaded methods

{
	my $html = new HTML::EasyTags();
	my ($does, $should);
	
	$does = $html->p( "some text" );
	$should = "\n<P>some text</P>";
	result( $does eq $should, "p( 'some text' ) returns '".vis($does)."'" );
	
	$does = $html->p_start( "some text" );
	$should = "\n<P>some text";
	result( $does eq $should, "p_start( 'some text' ) returns '".vis($does)."'" );
	
	$does = $html->p_end( "some text" );
	$should = "\n</P>";
	result( $does eq $should, "p_end( 'some text' ) returns '".vis($does)."'" );
	
	$does = $html->p_pair( "some text" );
	$should = "\n<P>some text</P>";
	result( $does eq $should, "p_pair( 'some text' ) returns '".vis($does)."'" );
	
	$does = $html->p_group( "some text" );
	$should = "\n<P>some text</P>";
	result( $does eq $should, "p_group( 'some text' ) returns '".vis($does)."'" );
	
	$does = $html->p_group( ['some','text'] );
	$should = "\n<P>some</P>\n<P>text</P>";
	result( $does eq $should, "p_group( ['some','text'] ) returns '".vis($does)."'" );
	
	$does = $html->a( href => 'url', text => 'here' );
	$should = "\n<A HREF=\"url\">here</A>";
	result( $does eq $should, "a( href => 'url', text => 'here' ) returns '".vis($does)."'" );
	
	$does = $html->input_group( -type => 'checkbox', -name => 'words',
		-value => ['eenie', 'meenie', 'minie', 'moe'], -checked => [1, 0, 1, 0],
		-text => ['Eenie', 'Meenie', 'Minie', 'Moe'] );
	$should = "\n<INPUT TYPE=\"checkbox\" NAME=\"words\" CHECKED VALUE=\"eenie\">Eenie".
		"\n<INPUT TYPE=\"checkbox\" NAME=\"words\" VALUE=\"meenie\">Meenie".
		"\n<INPUT TYPE=\"checkbox\" NAME=\"words\" CHECKED VALUE=\"minie\">Minie".
		"\n<INPUT TYPE=\"checkbox\" NAME=\"words\" VALUE=\"moe\">Moe";
	result( $does eq $should, "input_group( -type => 'checkbox', -name => ".
		"'words', -value => ['eenie', 'meenie', 'minie', 'moe'], -checked => ".
		"[1, 0, 1, 0], -text => ['Eenie', 'Meenie', 'Minie', 'Moe'] ) ".
		"returns '".vis($does)."'" );
	
	$does = serialize( $html->p_group( text => ['some','text'], list => 1 ) );
	$should = serialize( [ "\n<P>some</P>", "\n<P>text</P>" ] );
	result( $does eq $should, "p_group( text => ['some','text'], list => 1 ) returns '".vis($does)."'" );
	
	$html->groups_by_default( 0 );
	$does = $html->p( text => ['some','text'], list => 1 );
	$does =~ s/\(.*?\)/()/;
	$should = "\n<P>ARRAY()</P>";
	result( $does eq $should, "p( text => ['some','text'], list => 1 ) under no group by def returns '".vis($does)."'" );
	
	$html->groups_by_default( 1 );
	$does = serialize( $html->p( text => ['some','text'], list => 1 ) );
	$should = serialize( [ "\n<P>some</P>", "\n<P>text</P>" ] );
	result( $does eq $should, "p( text => ['some','text'], list => 1 ) under yes group by def returns '".vis($does)."'" );
}

######################################################################
# test start_html()

{
	my $html = new HTML::EasyTags();
	my ($does, $should);
	
	$does = $html->start_html();
	$should = "\n<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\">\n<HTML>".
		"\n<HEAD>\n<TITLE>Untitled Document</TITLE>\n</HEAD>\n<BODY>";
	result( $does eq $should, "start_html() returns '".vis($does)."'" );
	
	$does = $html->start_html( 'my page' );
	$should = "\n<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\">\n<HTML>".
		"\n<HEAD>\n<TITLE>my page</TITLE>\n</HEAD>\n<BODY>";
	result( $does eq $should, "start_html( 'my page' ) returns '".vis($does)."'" );
	
	$does = $html->start_html( 'my page', '<META>' );
	$should = "\n<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\">\n<HTML>".
		"\n<HEAD>\n<TITLE>my page</TITLE><META>\n</HEAD>\n<BODY>";
	result( $does eq $should, "start_html( 'my page', '<META>' ) returns '".vis($does)."'" );
	
	$does = $html->start_html( 'my page', '<META>', {bgcolor=>'white'} );
	$should = "\n<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\">\n<HTML>".
		"\n<HEAD>\n<TITLE>my page</TITLE><META>\n</HEAD>\n<BODY BGCOLOR=\"white\">";
	result( $does eq $should, "start_html( 'my page', '<META>', {bgcolor=>'white'} ) returns '".vis($does)."'" );
}
	
######################################################################
# test end_html()

{
	my $html = new HTML::EasyTags();
	my ($does, $should);
	
	$does = $html->end_html();
	$should = "\n</BODY>\n</HTML>";
	result( $does eq $should, "end_html() returns '".vis($does)."'" );
}
	
######################################################################

1;