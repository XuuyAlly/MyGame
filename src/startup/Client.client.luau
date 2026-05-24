local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HotbarServiceClient = require(ReplicatedStorage.Source.Features.Hotbar.HotbarServiceClient)
local MiscServiceClient = require(ReplicatedStorage.Source.Features.Misc.MiscServiceClient)
local WeaponServiceClient = require(ReplicatedStorage.Source.Features.Weapon.WeaponServiceClient)
local MountUI = require(script.Parent.MountUI)
local DataService = require(ReplicatedStorage.Packages.DataService).client

DataService:init()
MountUI()
WeaponServiceClient:init()
HotbarServiceClient:init()
MiscServiceClient:init()
