# frozen_string_literal: true

# Load shared dependency tags from tree_haver
#
# This file follows the standard spec/support/ convention. The actual
# implementation is in tree_haver so it can be shared across all gems
# in the TreeHaver/ast-merge family.
#
# For debugging, use TREE_HAVER_DEBUG=true which prints dependency
# availability in a way that respects backend isolation (FFI vs MRI).
#
# @see TreeHaver::RSpec::DependencyTags

require "tree_haver/rspec"

# Alias for convenience in existing specs
BashMergeDependencies = TreeHaver::RSpec::DependencyTags
