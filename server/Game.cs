using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using PlayerIO.GameLibrary;
using System.Drawing;

namespace DuelParty {
	public class Player : BasePlayer {
		public string Name;
        public int Num;
	}

	public class DuelParty : Game<Player> {

        private enum MessageType {
            JOIN,
            LEFT,
            PLAYER_DATA_REQUEST,
            DICE_ROLL,
            DIALOG_BOX,
            DIR_SELECT,
            FOCUS_CHANGE
        }

        private Dictionary<int, Player> _playersByNum = new Dictionary<int, Player>();

		public override void GameStarted() {
            if (Int32.Parse(RoomData["numPlayers"]) > 4) {
                Console.WriteLine("WARNING: CANNOT HAVE MORE THAN 4 PLAYERS IN ONE ROOM!");
            }
            RoomData["onlineUsers"] = 0.ToString();

			Console.WriteLine("Game started with ID: " + RoomId);
		}

		public override void GameClosed() {
            Console.WriteLine("Game closed with ID: " + RoomId);
		}

		public override void UserJoined(Player player) {
            player.Name = player.JoinData["name"];

            //Find first available player number
            for (int i = 0; i < 4; i++) {
                if (!_playersByNum.ContainsKey(i)) {
                    player.Num = i;
                    break;
                }
            }

            _playersByNum.Add(player.Num, player);
            RoomData["onlineUsers"] = PlayerCount.ToString();
            RoomData.Save();

            object[] messageParams = { player.ConnectUserId, player.Name, player.Num, PlayerCount, Int32.Parse(RoomData["numPlayers"]) };
            Broadcast(MessageTypeString(MessageType.JOIN), messageParams);
		}

		public override void UserLeft(Player player) {
            _playersByNum.Remove(player.Num);
            
            object[] messageParams = { player.ConnectUserId, player.Name, player.Num, PlayerCount, Int32.Parse(RoomData["numPlayers"]) };
            Broadcast(MessageTypeString(MessageType.LEFT), messageParams);
		}

        public override void GotMessage(Player player, Message message) {
            Console.WriteLine("Recieved message with type: " + message.Type + " with " + message.Count + " arguments.");

            MessageType type = (MessageType)Enum.Parse(typeof(MessageType), message.Type);
			switch(type) {
                case MessageType.PLAYER_DATA_REQUEST:
                    player.Send(PlayerDataRequestMessage());
					break;
                default:
                    //Bounce message to all other players
                    foreach (KeyValuePair<int, Player> p in _playersByNum) {
                        if (player.Num != p.Key) p.Value.Send(message);
                    }
                    break;
			}
		}

        private Message PlayerDataRequestMessage() {
            //Sends an array of player data to the client
            Message playerData = Message.Create(MessageTypeString(MessageType.PLAYER_DATA_REQUEST));

            List<object> netIds = new List<object>();
            List<object> names = new List<object>();
            foreach (KeyValuePair<int, Player> p in _playersByNum) {
                netIds.Add(p.Value.ConnectUserId);
                names.Add(p.Value.Name);
            }
            playerData.Add(PlayerCount);
            playerData.Add(Int32.Parse(RoomData["numPlayers"]));
            playerData.Add(ListToString(netIds));
            playerData.Add(ListToString(names));

            return playerData;
        }

		public override System.Drawing.Image GenerateDebugImage() {
			var image = new Bitmap(400,400);
			using(var g = Graphics.FromImage(image)) {
				g.FillRectangle(Brushes.Blue, 0, 0, image.Width, image.Height);
				g.DrawString(DateTime.Now.ToString(), new Font("Verdana",20F),Brushes.Orange, 10,10);
			}
			return image;
		}

		[DebugAction("Play", DebugAction.Icon.Play)]
		public void PlayNow() {
			Console.WriteLine("The play button was clicked!");
		}

        private String MessageTypeString(MessageType x) {
            return Enum.GetName(typeof(MessageType), x);
        }

        private String ListToString(List<object> x) {
            StringBuilder builder = new StringBuilder();
            foreach (object i in x)
            {
                builder.Append(i).Append(",");
            }
            return builder.ToString();
        }
	}
}