function landmark = add_landmark()

landmark = struct('mu',[0;0;0]','Sigma',zeros(3),'descriptor_mu',zeros(64,1),'desc_Sigma',zeros(64),'FramesTracked',0);
end