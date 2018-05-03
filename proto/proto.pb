
ë
server/login.proto")
	GS2CHello
	timestamp (R	timestamp"*
GS2CLoginError
errcode (Rerrcode"D
RoleInfo
pid (Rpid
name (	Rname
icon (	Ricon"8
GS2CSelectRole&
	role_list (2	.RoleInfoRroleList
à

base.proto"#
GS2CSendMessage
msg (	Rmsg"¬

PlayerProp
mask (Rmask
pid (Rpid
name (	Rname
exp (Rexp
grade (Rgrade
school (Rschool
sex (Rsex
icon (Ricon
n
server/player.proto
base.proto"8
GS2CRefreshPlayerProp
prop (2.PlayerPropRprop"
GS2CLoginFinish
­
server/iteam.proto"_
ItemUnit
sid (Rsid
item_id (RitemId
amount (Ramount
pos (Rpos"6
GS2CItemList&
	item_list (2	.ItemUnitRitemList
æ
client/login.proto">
C2GSLoginAccount
account (	Raccount
pwd (	Rpwd"R
C2GSCreateRole
account (	Raccount
name (	Rname
icon (Ricon"<
C2GSSelectRole
account (	Raccount
pid (Rpid