from re import compile
from sys import exit, argv
import numpy as np

def build_array(tp, nk, nb, fn):
# GGA and HSE data:
# k-point    34 :       0.3000    0.2000    0.2000
#  band No.  band energies     occupation
#      1     -11.4239      2.00000
# GW data:
# k-point  34 :       0.3000    0.2000    0.2000
#  band No.  KS-energies  QP-energies   sigma(KS)   V_xc(KS)     V^pw_x(r,r')   Z            occupation
#
#      1     -13.6327     -13.8221     -18.7012     -18.4394     -24.9401       0.7235       2.0000       0.2828
   RE1 = compile('^ k-point +[0-9]{1,3} :   (    [0-9]\.[0-9]{4}){3}')

   # Get file contents
   try:
      file = open(fn, 'r')
      filedata = file.readlines()
      file.close()
   except FileNotFoundError:
      exit(fn + ' is missing')
   
   # Now regardless of ref or test, we have nb correct. Pull out band structure.
   data = iter(filedata)
   block = np.zeros((nk, nb), dtype=np.float)
   i = -1
   while True:
      t2 = next(data)
      if RE1.match(t2):
         i += 1
         next(data)
         if tp == 'gw':  # Extra blank line
            next(data)
         KS_energies = []
         for j in range(nb):
            KS_energies.append(np.float(next(data).split()[1]))
         block[i,:] = np.transpose(np.array(KS_energies))
      if i == numkpoints-1:
         break

   # Make sure block is not still all zeros
   try:
      np.testing.assert_equal(block, np.zeros((nk, nb), dtype=np.float))
   except AssertionError:  # Not equal, so OK
      return block
   else:  # Equal, so couldn't find data
      exit('Could not find data in ' + fn)

def validate(tp, test_array, ref_array):
   diff = None
   try:
      np.testing.assert_allclose(test_array, ref_array, rtol=1e-3) # Test equality to 1 part in 10^3
      OK = True
   except AssertionError:
      OK = False
      t = np.not_equal(test_array, ref_array)
      diff = (test_array[t], ref_array[t])
   return OK, diff

if __name__ == '__main__':

   try: # A filename has been supplied
      test_filename = argv[1]+'/'+argv[2]+'/OUTCAR'
      run_type = argv[2]
      RE_rank = compile('running on +(?P<ranks>[0-9]{1,3}) total cores')
      reference_filename = 'NREL-results/OUTCAR-'+argv[2]+'.ref'
      if argv[2]!='gw':
          numbands=640  # Only check the first 640 bands for non-gw
      else:
          numbands=160  # And only check 160 for gw
   except IndexError:
      exit('Usage: validate.py [run directory] [runtype=gga or hse or gw]')

   numkpoints = 63  # This is set by INCAR, fixed for all runs

   reference = build_array(run_type, numkpoints, numbands, reference_filename)
   test = build_array(run_type, numkpoints, numbands, test_filename)
   IS_OK = validate(run_type, test, reference)
 
   if IS_OK[0]:
      print('Benchmark 1 {} ranks validated'.format(run_type))
   else:
      print('Benchmark 1 {} ranks not validated'.format(run_type))
      print('Differences found for '+str(len(IS_OK[1][0]))+' items')
      print('Test data')
      print(IS_OK[1][0])
      print('Reference data')
      print(IS_OK[1][1])
