RARS_JAR = rars1_6.jar
RARS = java -jar $(RARS_JAR)
DIFF = diff -u --strip-trailing-cr -Z
TEST_DIR = tests
TEST_FILES = $(wildcard $(TEST_DIR)/test*.in)

.PHONY: all test-all test clean

all: calculadora.s
	$(RARS) nc se1 ae1 me calculadora.s

test-all: $(TEST_FILES:.in=.test)

test: $(TEST_DIR)/test$(TEST_NUM).test

%.test: %.in %.out calculadora.s
	@echo "Running test $*..."
	@$(RARS) nc se1 ae1 me calculadora.s < $< | tr -d '\r' > $*.tmp
	@$(DIFF) $*.out $*.tmp || (echo "Test $* failed!" && exit 1)
	@echo "Test $* passed!"
	@rm -f $*.tmp

clean:
	rm -f $(TEST_DIR)/*.tmp
