#!/usr/bin/env th
--
-- Outputs the number of parameters in a network for a single image
-- in evaluation mode.

require 'torch'
require 'nn'
require 'dpnn'

torch.setdefaulttensortype('torch.FloatTensor')

local cmd = torch.CmdLine()
cmd:text()
cmd:text('Network Size.')
cmd:text()
cmd:text('Options:')

cmd:option('-model', './models/openface/nn4.v1.t7', 'Path to model.')
cmd:option('-imgDim', 96, 'Image dimension. nn1=224, nn4=96')
cmd:option('-numIter', 50)
cmd:option('-cuda', false)
cmd:text()

opt = cmd:parse(arg or {})
-- print(opt)

net = torch.load(opt.model):float()
net:evaluate()
-- print(net)

local img = torch.randn(opt.numIter, 1, 3, opt.imgDim, opt.imgDim)

if opt.cuda then
   require 'cutorch'
   require 'cunn'
   net = net:cuda()
   img = img:cuda()
end

times = torch.Tensor(opt.numIter)

for i=1,opt.numIter do
   timer = torch.Timer()
   rep = net:forward(img[i])
   times[i] = 1000.0*timer:time().real
end

print(string.format('Single image forward pass: %.2f ms +/- %.2f ms',
                    torch.mean(times), torch.std(times)))
