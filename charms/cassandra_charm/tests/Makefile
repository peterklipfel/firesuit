# Usage e.g.:
#   make -j5                       ## Fast(er)
#   make -j5 TESTS=test_simpleauth ## Single test accross versions
#   make test-0.7                  ## It fails (missing seeds feature)
TESTS=all

all: test

test: test-1.0 test-1.1 test-1.2 test-2.0

test-%: cassandra-%/conf
	./test-cassandra-conf.sh test $* $(TESTS)

cassandra-%/conf:
	install -d $@
	wget -qO $@/cassandra-env.sh https://raw.github.com/apache/cassandra/$@/cassandra-env.sh && \
	wget -qO $@/cassandra.yaml https://raw.github.com/apache/cassandra/$@/cassandra.yaml || rm -rf $@

clean:
	./test-cassandra-conf.sh clean
	rm -rf cassandra-[0-9].*

.PHONY: all test clean

.PRECIOUS: cassandra-%/conf
