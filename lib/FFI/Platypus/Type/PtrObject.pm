package FFI::Platypus::Type::PtrObject;

use strict;
use warnings;
use FFI::Platypus 1.11;
use Carp ();
use 5.008001;

# ABSTRACT: Platypus custom type for an object wrapped around an opaque pointer
# VERSION

sub ffi_custom_type_api_1
{
  my(undef, undef, $wrapper_class) = @_;
}

1;


