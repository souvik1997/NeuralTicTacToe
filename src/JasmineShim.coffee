shim = () -> 0
root = module.exports ? this
root.jasmineEnabled = describe?
root.describe = describe ? shim