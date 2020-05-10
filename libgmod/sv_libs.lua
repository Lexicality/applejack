-- TODO: These need arguments and EmmyLua annotations

weapons = {}
function weapons.IsBasedOn(p1,p2) end
function weapons.GetList() end
function weapons.GetStored(p1) end
function weapons.OnLoaded() end
function weapons.Register(p1,p2) end
function weapons.Get(p1,p2) end

player_manager = {}
function player_manager.SetPlayerClass(p1,p2) end
function player_manager.OnPlayerSpawn(p1,p2) end
function player_manager.AddValidModel(p1,p2) end
function player_manager.TranslatePlayerHands(p1) end
function player_manager.RunClass(...) end
function player_manager.TranslateToPlayerModelName(p1) end
function player_manager.AddValidHands(p1,p2,p3,p4) end
function player_manager.GetPlayerClass(p1) end
function player_manager.AllValidModels() end
function player_manager.ClearPlayerClass(p1) end
function player_manager.TranslatePlayerModel(p1) end
function player_manager.RegisterClass(p1,p2,p3) end

constraint = {}
function constraint.NoCollide(p1,p2,p3,p4) end
function constraint.Slider(p1,p2,p3,p4,p5,p6,p7,p8) end
function constraint.GetAllConstrainedEntities(p1,p2) end
function constraint.FindConstraintEntity(p1,p2) end
function constraint.Weld(p1,p2,p3,p4,p5,p6,p7) end
function constraint.FindConstraint(p1,p2) end
function constraint.FindConstraints(p1,p2) end
function constraint.ForgetConstraints(p1) end
function constraint.Hydraulic(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15) end
function constraint.HasConstraints(p1) end
function constraint.Keepupright(p1,p2,p3,p4) end
function constraint.Muscle(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16) end
function constraint.GetTable(p1) end
function constraint.Winch(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14) end
function constraint.Ballsocket(p1,p2,p3,p4,p5,p6,p7,p8) end
function constraint.AddConstraintTableNoDelete(p1,p2,p3,p4,p5) end
function constraint.Motor(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17) end
function constraint.CreateKeyframeRope(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11) end
function constraint.RemoveAll(p1) end
function constraint.Elastic(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12) end
function constraint.Find(p1,p2,p3,p4,p5) end
function constraint.Axis(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12) end
function constraint.AdvBallsocket(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19) end
function constraint.RemoveConstraints(p1,p2) end
function constraint.CanConstrain(p1,p2) end
function constraint.AddConstraintTable(p1,p2,p3,p4,p5) end
function constraint.Pulley(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12) end
function constraint.Rope(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12) end
function constraint.CreateStaticAnchorPoint(p1) end

list = {}
function list.Contains(p1,p2) end
function list.HasEntry(p1,p2) end
function list.Set(p1,p2,p3) end
function list.Add(p1,p2) end
function list.GetForEdit(p1) end
function list.Get(p1) end

hook = {}
function hook.Run(...) end
function hook.Remove(p1,p2) end
function hook.Call(...) end
function hook.GetTable() end
function hook.Add(p1,p2,p3) end

gameevent = {}
function gameevent.Listen(...) end

game = {}
function game.GetAmmoData(...) end
function game.SetTimeScale(...) end
function game.GetAmmoForce(...) end
function game.IsDedicated(...) end
function game.GetMapNext(...) end
function game.KickID(...) end
function game.GetAmmoPlayerDamage(...) end
function game.MapLoadType(...) end
function game.GetMapVersion(...) end
function game.GetSkillLevel(...) end
function game.LoadNextMap(...) end
function game.GetAmmoTypes(...) end
function game.SetSkillLevel(...) end
function game.GetIPAddress(...) end
function game.GetAmmoDamageType(...) end
function game.GetAmmoID(...) end
function game.SinglePlayer(...) end
function game.GetAmmoName(...) end
function game.BuildAmmoTypes() end
function game.GetAmmoMax(...) end
function game.GetTimeScale(...) end
function game.GetAmmoNPCDamage(...) end
function game.StartSpot(...) end
function game.GetGlobalState(...) end
function game.SetGlobalState(...) end
function game.SetGlobalCounter(...) end
function game.GetGlobalCounter(...) end
function game.MaxPlayers(...) end
function game.MountGMA(...) end
function game.GetMap(...) end
function game.RemoveRagdolls(...) end
function game.AddParticles(...) end
function game.AddAmmoType(p1) end
function game.CleanUpMap(...) end
function game.GetWorld(...) end
function game.ConsoleCommand(...) end
function game.AddDecal(...) end

ai_schedule = {}
function ai_schedule.New(p1) end

jit = {}
function jit.status(...) end
function jit.on(...) end
jit.os = Windows
function jit.off(...) end
function jit.flush(...) end
function jit.attach(...) end
jit.util = {}
function jit.util.funcbc(...) end
function jit.util.funck(...) end
function jit.util.funcinfo(...) end
function jit.util.traceinfo(...) end
function jit.util.tracek(...) end
function jit.util.tracesnap(...) end
function jit.util.traceir(...) end
function jit.util.tracemc(...) end
function jit.util.ircalladdr(...) end
function jit.util.traceexitstub(...) end
function jit.util.funcuvname(...) end
jit.opt = {}
function jit.opt.start(...) end

bit = {}
function bit.rol(...) end
function bit.rshift(...) end
function bit.ror(...) end
function bit.bswap(...) end
function bit.bxor(...) end
function bit.bor(...) end
function bit.arshift(...) end
function bit.bnot(...) end
function bit.tobit(...) end
function bit.lshift(...) end
function bit.tohex(...) end
function bit.band(...) end

motionsensor = {}
function motionsensor.ChooseBuilderFromEntity(p1) end
function motionsensor.ProcessAnglesTable(p1,p2,p3,p4) end
function motionsensor.ProcessPositionTable(p1,p2) end
function motionsensor.ProcessAngle(p1,p2,p3,p4,p5,p6,p7) end
function motionsensor.BuildSkeleton(p1,p2,p3) end
motionsensor.DebugBones = {}

drive = {}
function drive.Move(p1,p2) end
function drive.PlayerStopDriving(p1) end
function drive.End(p1,p2) end
function drive.Register(p1,p2,p3) end
function drive.StartMove(p1,p2,p3) end
function drive.CalcView(p1,p2) end
function drive.CreateMove(p1) end
function drive.Start(p1,p2) end
function drive.GetMethod(p1) end
function drive.FinishMove(p1,p2) end
function drive.DestroyMethod(p1) end
function drive.PlayerStartDriving(p1,p2,p3) end

utf8 = {}
function utf8.codepoint(p1,p2,p3) end
utf8.charpattern = [%z--][-]*
function utf8.len(p1,p2,p3) end
function utf8.force(p1) end
function utf8.offset(p1,p2,p3) end
function utf8.char(...) end
function utf8.codes(p1) end

cookie = {}
function cookie.GetString(p1,p2) end
function cookie.Set(p1,p2) end
function cookie.GetNumber(p1,p2) end
function cookie.Delete(p1) end

timer = {}
function timer.Exists(...) end
function timer.UnPause(...) end
function timer.Toggle(...) end
function timer.Adjust(...) end
function timer.Create(...) end
function timer.Destroy(...) end
function timer.Stop(...) end
function timer.Start(...) end
function timer.Remove(...) end
function timer.Check(...) end
function timer.RepsLeft(...) end
function timer.TimeLeft(...) end
function timer.Simple(...) end
function timer.Pause(...) end

http = {}
function http.Fetch(p1,p2,p3,p4) end
function http.Post(p1,p2,p3,p4,p5) end

cvars = {}
function cvars.GetConVarCallbacks(p1,p2) end
function cvars.OnConVarChanged(p1,p2,p3) end
function cvars.Number(p1,p2) end
function cvars.Bool(p1,p2) end
function cvars.String(p1,p2) end
function cvars.AddChangeCallback(p1,p2,p3) end
function cvars.RemoveChangeCallback(p1,p2) end

usermessage = {}
function usermessage.Hook(...) end
function usermessage.IncomingMessage(p1,p2) end
function usermessage.GetTable() end

construct = {}
function construct.Magnet(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15) end
function construct.SetPhysProp(p1,p2,p3,p4,p5) end

duplicator = {}
function duplicator.DoFlex(p1,p2,p3) end
function duplicator.FindEntityClass(p1) end
function duplicator.ClearEntityModifier(p1,p2) end
duplicator.EntityModifiers = {}
function duplicator.CopyEntTable(p1) end
function duplicator.RegisterEntityModifier(p1,p2) end
function duplicator.RegisterBoneModifier(p1,p2) end
function duplicator.GenericDuplicatorFunction(p1,p2) end
function duplicator.Paste(p1,p2,p3) end
function duplicator.WorkoutSize(p1) end
function duplicator.RegisterEntityClass(...) end
function duplicator.DoGenericPhysics(p1,p2,p3) end
function duplicator.CreateEntityFromTable(p1,p2) end
duplicator.ConstraintType = {}
function duplicator.SetLocalAng(p1) end
duplicator.EntityClasses = {}
function duplicator.SetLocalPos(p1) end
function duplicator.CreateConstraintFromTable(p1,p2) end
function duplicator.GetAllConstrainedEntitiesAndConstraints(p1,p2,p3) end
function duplicator.Copy(p1,p2) end
function duplicator.ApplyEntityModifiers(p1,p2) end
function duplicator.StoreEntityModifier(p1,p2,p3) end
function duplicator.DoGeneric(p1,p2) end
function duplicator.StoreBoneModifier(p1,p2,p3,p4) end
function duplicator.CopyEnts(p1) end
function duplicator.RegisterConstraint(...) end
function duplicator.Allow(p1) end
function duplicator.IsAllowed(p1) end
duplicator.BoneModifiers = {}
function duplicator.BoneModifiers.physprops(p1,p2,p3,p4,p5) end
function duplicator.RemoveMapCreatedEntities() end
function duplicator.DoBoneManipulator(p1,p2) end
function duplicator.ApplyBoneModifiers(p1,p2) end

cleanup = {}
function cleanup.ReplaceEntity(p1,p2) end
function cleanup.CC_AdminCleanup(p1,p2,p3) end
function cleanup.Register(p1) end
function cleanup.GetList() end
function cleanup.Add(p1,p2,p3) end
function cleanup.GetTable() end
function cleanup.CC_Cleanup(p1,p2,p3) end

undo = {}
function undo.AddEntity(p1) end
function undo.Finish(p1) end
function undo.SetCustomUndoText(p1) end
function undo.Create(p1) end
function undo.AddFunction(...) end
function undo.Do_Undo(p1) end
function undo.SetPlayer(p1) end
function undo.GetTable() end
function undo.ReplaceEntity(p1,p2) end

team = {}
function team.GetPlayers(p1) end
function team.GetScore(p1) end
function team.SetClass(p1,p2) end
function team.GetSpawnPoints(p1) end
function team.GetSpawnPoint(p1) end
function team.TotalDeaths(p1) end
function team.NumPlayers(p1) end
function team.TotalFrags(p1) end
function team.SetColor(p1,p2) end
function team.AddScore(p1,p2) end
function team.GetAllTeams() end
function team.GetColor(p1) end
function team.GetName(p1) end
function team.Joinable(p1) end
function team.GetClass(p1) end
function team.Valid(p1) end
function team.SetUp(p1,p2,p3,p4) end
function team.SetScore(p1,p2) end
function team.SetSpawnPoint(p1,p2) end
function team.BestAutoJoinTeam() end

numpad = {}
function numpad.OnUp(...) end
function numpad.Toggle(p1,p2) end
function numpad.FromButton() end
function numpad.Register(p1,p2) end
function numpad.Remove(p1) end
function numpad.OnDown(...) end
function numpad.Deactivate(p1,p2,p3) end
function numpad.Activate(p1,p2,p3) end

scripted_ents = {}
function scripted_ents.GetSpawnable() end
function scripted_ents.IsBasedOn(p1,p2) end
function scripted_ents.Alias(p1,p2) end
function scripted_ents.GetList() end
function scripted_ents.GetType(p1) end
function scripted_ents.GetMember(p1,p2) end
function scripted_ents.GetStored(p1) end
function scripted_ents.OnLoaded() end
function scripted_ents.Register(p1,p2) end
function scripted_ents.Get(p1,p2) end

gamemode = {}
function gamemode.Call(...) end
function gamemode.Register(p1,p2,p3) end
function gamemode.Get(p1) end

properties = {}
function properties.OnScreenClick(p1,p2) end
function properties.GetHovered(p1,p2) end
function properties.OpenEntityMenu(p1,p2) end
properties.List = {}
function properties.CanBeTargeted(p1,p2) end
function properties.Add(p1,p2) end

ai = {}
function ai.GetTaskID(...) end
function ai.GetScheduleID(...) end

sound = {}
function sound.AddSoundOverrides(...) end
function sound.GetProperties(...) end
function sound.Add(...) end
function sound.Play(...) end
function sound.GetTable(...) end

physenv = {}
function physenv.SetAirDensity(...) end
function physenv.SetPerformanceSettings(...) end
function physenv.GetGravity(...) end
function physenv.GetAirDensity(...) end
function physenv.GetPerformanceSettings(...) end
function physenv.AddSurfaceData(...) end
function physenv.SetGravity(...) end

effects = {}
function effects.BeamRingPoint(...) end
function effects.Bubbles(...) end
function effects.BubbleTrail(...) end

system = {}
function system.BatteryPower(...) end
function system.AppTime(...) end
function system.UpTime(...) end
function system.IsOSX(...) end
function system.SteamTime(...) end
function system.IsLinux(...) end
function system.GetCountry(...) end
function system.IsWindows(...) end
function system.HasFocus(...) end

debugoverlay = {}
function debugoverlay.Line(...) end
function debugoverlay.BoxAngles(...) end
function debugoverlay.Sphere(...) end
function debugoverlay.Axis(...) end
function debugoverlay.Box(...) end
function debugoverlay.Grid(...) end
function debugoverlay.SweptBox(...) end
function debugoverlay.EntityTextAtPosition(...) end
function debugoverlay.Triangle(...) end
function debugoverlay.Cross(...) end
function debugoverlay.ScreenText(...) end
function debugoverlay.Text(...) end

net = {}
function net.Broadcast(...) end
function net.Receive(p1,p2) end
function net.WriteInt(...) end
function net.ReadInt(...) end
function net.WriteFloat(...) end
net.Receivers = {}
function net.ReadType(p1) end
function net.BytesWritten(...) end
function net.ReadAngle(...) end
function net.SendPVS(...) end
function net.SendPAS(...) end
function net.WriteBit(...) end
function net.ReadHeader(...) end
function net.Send(...) end
function net.BytesLeft(...) end
function net.ReadVector(...) end
function net.WriteNormal(...) end
function net.WriteUInt(...) end
net.ReadVars = {}
function net.WriteType(p1) end
function net.ReadTable() end
net.WriteVars = {}
function net.ReadString(...) end
function net.ReadMatrix(...) end
function net.Incoming(p1,p2) end
function net.WriteColor(p1) end
function net.WriteDouble(...) end
function net.ReadColor() end
function net.ReadEntity() end
function net.ReadNormal(...) end
function net.WriteEntity(p1) end
function net.ReadBool() end
function net.WriteData(...) end
function net.WriteBool(...) end
function net.ReadUInt(...) end
function net.ReadData(...) end
function net.WriteTable(p1) end
function net.WriteMatrix(...) end
function net.WriteAngle(...) end
function net.ReadDouble(...) end
function net.SendOmit(...) end
function net.WriteVector(...) end
function net.WriteString(...) end
function net.ReadBit(...) end
function net.Start(...) end
function net.ReadFloat(...) end

umsg = {}
function umsg.PoolString(...) end
function umsg.Char(...) end
function umsg.Long(...) end
function umsg.Bool(...) end
function umsg.Vector(...) end
function umsg.Entity(...) end
function umsg.Start(...) end
function umsg.Float(...) end
function umsg.String(...) end
function umsg.VectorNormal(...) end
function umsg.End(...) end
function umsg.Short(...) end
function umsg.Angle(...) end

ents = {}
function ents.FindInCone(...) end
function ents.FindInBox(...) end
function ents.FindByClassAndParent(p1,p2) end
function ents.FireTargets(...) end
function ents.FindByModel(...) end
function ents.GetCount(...) end
function ents.Create(...) end
function ents.GetMapCreatedEntity(...) end
function ents.FindInSphere(...) end
function ents.GetEdictCount(...) end
function ents.FindByClass(...) end
function ents.GetByIndex(...) end
function ents.GetAll(...) end
function ents.FindInPVS(...) end
function ents.FindByName(...) end
function ents.FindAlongRay(...) end

hammer = {}
function hammer.SendCommand(...) end

engine = {}
function engine.LightStyle(...) end
function engine.CloseServer(...) end
function engine.GetAddons(...) end
function engine.ActiveGamemode(...) end
function engine.TickCount(...) end
function engine.GetGames(...) end
function engine.GetUserContent(...) end
function engine.GetGamemodes(...) end
function engine.TickInterval(...) end

file = {}
function file.Exists(...) end
function file.Write(p1,p2) end
function file.Append(p1,p2) end
function file.Rename(...) end
function file.Time(...) end
function file.Delete(...) end
function file.Size(...) end
function file.Read(p1,p2) end
function file.Open(...) end
function file.CreateDir(...) end
function file.IsDir(...) end
function file.Find(...) end

ai_task = {}
function ai_task.New() end

saverestore = {}
function saverestore.LoadGlobal(p1) end
function saverestore.WritableKeysInTable(p1) end
function saverestore.PreRestore() end
function saverestore.PreSave() end
function saverestore.AddRestoreHook(p1,p2) end
function saverestore.AddSaveHook(p1,p2) end
function saverestore.WriteTable(p1,p2) end
function saverestore.SaveEntity(p1,p2) end
function saverestore.LoadEntity(p1,p2) end
function saverestore.WriteVar(p1,p2) end
function saverestore.ReadVar(p1) end
function saverestore.ReadTable(p1) end
function saverestore.SaveGlobal(p1) end

player = {}
function player.GetByAccountID(p1) end
function player.GetCount(...) end
function player.GetByUniqueID(p1) end
function player.GetHumans(...) end
function player.GetBySteamID64(p1) end
function player.CreateNextBot(...) end
function player.GetAll(...) end
function player.GetBySteamID(p1) end
function player.GetByID(...) end
function player.GetBots(...) end

widgets = {}
function widgets.RenderMe(p1) end
function widgets.PlayerTick(p1,p2) end

gmod = {}
function gmod.GetGamemode(...) end

util = {}
function util.SharedRandom(...) end
function util.Base64Decode(...) end
function util.SteamIDTo64(...) end
function util.GetModelInfo(...) end
function util.SpriteTrail(...) end
function util.AddNetworkString(...) end
function util.TraceEntityHull(...) end
function util.NetworkStringToID(...) end
function util.BlastDamage(...) end
function util.JSONToTable(...) end
function util.GetPData(p1,p2,p3) end
function util.Decal(...) end
function util.GetSurfaceIndex(...) end
function util.SteamIDFrom64(...) end
function util.SetPData(p1,p2,p3) end
function util.RemovePData(p1,p2) end
function util.Stack() end
function util.IsValidRagdoll(...) end
function util.TimerCycle(...) end
function util.KeyValuesToTable(...) end
function util.KeyValuesToTablePreserveOrder(...) end
function util.Timer(p1) end
function util.DateStamp() end
function util.TypeToString(p1) end
function util.IsInWorld(...) end
function util.DistanceToLine(...) end
function util.StringToType(p1,p2) end
function util.ScreenShake(...) end
function util.NiceFloat(p1) end
function util.LocalToWorld(p1,p2,p3) end
function util.tobool(p1) end
function util.IsValidModel(...) end
function util.QuickTrace(p1,p2,p3) end
function util.GetPlayerTrace(p1,p2) end
function util.IntersectRayWithOBB(...) end
function util.TableToKeyValues(...) end
function util.PrecacheModel(...) end
function util.PrecacheSound(...) end
function util.Compress(...) end
function util.DecalMaterial(...) end
function util.RelativePathToFull(...) end
function util.IsValidPhysicsObject(p1,p2) end
function util.Base64Encode(...) end
function util.CRC(...) end
function util.Effect(...) end
function util.TraceEntity(...) end
function util.GetSurfacePropName(...) end
function util.BlastDamageInfo(...) end
function util.AimVector(...) end
function util.TraceLine(...) end
function util.IsValidProp(...) end
function util.IsModelLoaded(...) end
function util.TableToJSON(...) end
function util.GetSurfaceData(...) end
function util.IntersectRayWithPlane(...) end
function util.Decompress(...) end
function util.GetUserGroups() end
function util.TraceHull(...) end
function util.ParticleTracerEx(...) end
function util.NetworkIDToString(...) end
function util.ParticleTracer(...) end
function util.PointContents(...) end

baseclass = {}
function baseclass.Set(p1,p2) end
function baseclass.Get(p1) end

sql = {}
function sql.Query(...) end
function sql.QueryValue(p1) end
function sql.SQLStr(p1,p2) end
function sql.LastError() end
function sql.Commit() end
function sql.QueryRow(p1,p2) end
function sql.IndexExists(p1) end
function sql.TableExists(p1) end
function sql.Begin() end

navmesh = {}
function navmesh.ClearWalkableSeeds(...) end
function navmesh.SetMarkedArea(...) end
function navmesh.GetNavLadderByID(...) end
function navmesh.IsLoaded(...) end
function navmesh.IsGenerating(...) end
function navmesh.GetEditCursorPosition(...) end
function navmesh.Save(...) end
function navmesh.GetNavAreaCount(...) end
function navmesh.Reset(...) end
function navmesh.Load(...) end
function navmesh.BeginGeneration(...) end
function navmesh.GetGroundHeight(...) end
function navmesh.GetMarkedLadder(...) end
function navmesh.Find(...) end
function navmesh.SetMarkedLadder(...) end
function navmesh.GetMarkedArea(...) end
function navmesh.GetNavAreaByID(...) end
function navmesh.SetPlayerSpawnName(...) end
function navmesh.GetNearestNavArea(...) end
function navmesh.GetNavArea(...) end
function navmesh.AddWalkableSeed(...) end
function navmesh.GetPlayerSpawnName(...) end
function navmesh.CreateNavArea(...) end
function navmesh.GetAllNavAreas(...) end

resource = {}
function resource.AddFile(...) end
function resource.AddWorkshop(...) end
function resource.AddSingleFile(...) end

gmsave = {}
function gmsave.PlayerLoad(p1,p2) end
function gmsave.ShouldSaveEntity(p1,p2) end
function gmsave.LoadMap(p1,p2) end
function gmsave.SaveMap(p1) end
function gmsave.PlayerSave(p1) end

concommand = {}
function concommand.Run(p1,p2,p3,p4) end
function concommand.Remove(p1) end
function concommand.AutoComplete(p1,p2) end
function concommand.GetTable() end
function concommand.Add(p1,p2,p3,p4,p5) end