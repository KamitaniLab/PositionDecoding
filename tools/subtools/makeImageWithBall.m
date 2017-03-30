function [ Image ] = makeImageWithBall(BallCenter,radius,FieldSize)
%MAKEINPUTIMAGEWITHBALL Summary of this function goes here
%   Detailed explanation goes here
I=([1:FieldSize(1)]')*ones(1,FieldSize(2));
J=ones(FieldSize(1),1)*[1:FieldSize(2)];

Image=...
    (((BallCenter(2)-J).^2)+((BallCenter(1)-I).^2)) < (radius.^2);

%{
for index_y=1:FieldSize(1)
    for index_x=1:FieldSize(2)
        if (((BallCenter(2)-index_x).^2)+((BallCenter(1)-index_y).^2)) < (radius.^2)
            Image(index_y,index_x)=1;
        else
            Image(index_y,index_x)=0;
        end
    end
end
    %}
end


