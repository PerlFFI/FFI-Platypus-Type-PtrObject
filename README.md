# FFI::Platypus::Type::PtrObject ![linux](https://github.com/PerlFFI/FFI-Platypus-Type-PtrObject/workflows/linux/badge.svg)

Platypus custom type for an object wrapped around an opaque pointer

# SYNOPSIS

C:

```
#include <string.h>

typedef struct { char buffer[100] } foo_t;

void
set(foo_t *self, const char *value)
{
  strncpy(self->buffer, value, 100);
}

const char *
get(foo_t *self)
{
  return self->buffer;
}

foo_t *
clone(foo_t *self)
{
  foo_t *clone;
  clone = malloc(100);
  memcpy(clone->buffer, self->buffer, 100);
  return clone;
}
```

Perl:

```perl
my $ffi = FFI::Platypus->new( api => 1 );
$ffi->bundle;  # See FFI::Platypus::Bundle
$ffi->load_custom_type('::PtrObject', 'foo_t', 'Foo');

package Foo {
  use FFI::Platypus::Memory qw( malloc free );

  sub new
  {
    my $class = shift;
    bless {
      ptr => malloc(100),
    }, $class;
  }

  $ffi->attach( set   => ['foo_t','string']    );
  $ffi->attach( get   => ['foo_t'] => 'string' );
  $ffi->attach( clone => ['foo_t'] => 'foo_t'  );

  sub take_ownership
  {
    my($self) = @_;
    return delete $self->{ptr};
  }

  sub DESTROY
  {
    my($self) = @_;
    if(defined $self->{ptr})
    {
      free($self->{ptr});
    }
  }
}

my $foo = Foo->new;
$foo->set("hello there");
print $foo->get, "\n";    # hello there
my $bar = $foo->clone;
print $bar->get, "\n";    # hello there

Foo::get(undef);    # undef is not a Foo, throws exception

my $baz = bless { ptr => 0xdeadbeaf }, 'Baz';
Foo::get($baz);     # $baz is not a Foo, throws exception

# by calling take ownership, the pointer will be
# removed from $foo, so we now own the pointer.
my $ptr = $foo->take_ownership;

$foo->get;  # $foo no longer owns its pointer, throws an exception

# since $foo no longer is tracking the memory, we should free it
# manually ourselves.
use FFI::Platypus::Memory qw( free );
free $ptr;

# $bar will free its memory when it falls out of scope automatically
# since it still owns its pointer.
```

# DESCRIPTION

This is a helper type for [FFI::Platypus](https://metacpan.org/pod/FFI::Platypus) that handles type checking for the common
pattern where a Perl class is a simple wrapper around an opaque pointer.  The class
should be implemented as a hash reference, and the pointer itself is expected to be
stored on the `ptr` key.  If the caller of the interface (Perl) is responsible for
cleaning up the memory, then it normally should be done in the `DESTROY` method
(as above).

If you do not pass in the correct type, it will be detected before the C code is
called and an exception will be thrown.  (otherwise you would probably get a segment
violation SEGV).

# CAVEATS

Care needs to be taken that only the responsible party frees its pointers.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2020 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
