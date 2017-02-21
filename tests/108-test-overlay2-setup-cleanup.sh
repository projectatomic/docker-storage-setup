source $SRCDIR/libtest.sh

# Test "docker-storage-setup reset". Returns 0 on success and 1 on failure.
test_reset_overlay2() {
  local test_status=0
  local testname=`basename "$0"`
  local infile=${WORKDIR}/container-storage-setup
  local outfile=${WORKDIR}/container-storage

  cat << EOF > $infile
STORAGE_DRIVER=overlay2
EOF

 # Run docker-storage-setup
 $DSSBIN $infile $outfile >> $LOGS 2>&1

 # Test failed.
 if [ $? -ne 0 ]; then
    echo "ERROR: $testname: $DSSBIN failed." >> $LOGS
    rm -f $infile $outfile
    return 1
 fi

 if ! grep -q "overlay2" $outfile; then
    echo "ERROR: $testname: $outfile does not have string overlay2." >> $LOGS
    rm -f $infile $outfile
    return 1
 fi

 $DSSBIN --reset $infile $outfile >> $LOGS 2>&1
 if [ $? -ne 0 ]; then
    # Test failed.
    test_status=1
    echo "ERROR: $testname: $DSSBIN --reset $infile $outfile failed." >> $LOGS
 elif [ -e $outfile ]; then
    # Test failed.
    test_status=1
    echo "ERROR: $testname: $DSSBIN --reset $infile $outfile failed. $outfile still exists." >> $LOGS
 fi

 rm -f $infile $outfile
 return $test_status
}

# Create a overlay2 backend and then make sure the
# docker-storage-setup --reset
# cleans it up properly.
test_reset_overlay2