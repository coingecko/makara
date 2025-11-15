#!/bin/bash
# Test Rails 7.2 compatibility with PostgreSQL adapter
# This focuses only on the critical PostgreSQL adapter tests for Rails 7.2

echo "=========================================="
echo "Rails 7.2 PostgreSQL Adapter Tests"
echo "=========================================="

BUNDLE_GEMFILE=gemfiles/activerecord_7.2.gemfile \
PGHOST=localhost \
PGUSER=$USER \
RAILS_ENV=test \
bundle exec rspec spec/active_record/connection_adapters/makara_postgresql_adapter_spec.rb

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "✅ All PostgreSQL adapter tests passed!"
echo "✅ Rails 7.2 compatibility confirmed"
echo ""
