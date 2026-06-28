using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
using UnityEngine.Networking;

namespace SimpleLeaderboardPro
{
    [Serializable]
    public class ScorePayload
    {
        public string board_id;
        public string player_id;
        public string player_name;
        public int score;
        public string metadata; // JSON string
    }

    [Serializable]
    public class ScoreItem
    {
        public int rank;
        public string player_id;
        public string player_name;
        public int score;
        public string created_at;
    }

    [Serializable]
    public class LeaderboardResponse
    {
        public bool success;
        public string period;
        public string board_id;
        public List<ScoreItem> leaderboard;
    }

    [Serializable]
    public class SubmitResponse
    {
        public bool success;
        public string message;
        public string error;
    }

    public class LeaderboardManager : MonoBehaviour
    {
        public static LeaderboardManager Instance { get; private set; }

        [Header("Backend Settings")]
        [Tooltip("Cloudflare Workers API URL (No trailing slash)")]
        public string apiUrl = "http://localhost:8787";

        [Tooltip("Leaderboard Identifier")]
        public string boardId = "default";

        public event Action<bool, string> OnScoreSubmitted;
        public event Action<string, List<ScoreItem>> OnLeaderboardLoaded;

        private void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(gameObject);
                return;
            }
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }

        public void SubmitScore(string playerId, string playerName, int score, string metadataJson = "{}")
        {
            StartCoroutine(SubmitScoreRoutine(playerId, playerName, score, metadataJson));
        }

        private IEnumerator SubmitScoreRoutine(string playerId, string playerName, int score, string metadataJson)
        {
            if (string.IsNullOrEmpty(apiUrl))
            {
                Debug.LogError("[LeaderboardManager] API URL is not configured!");
                OnScoreSubmitted?.Invoke(false, "API URL is not configured.");
                yield break;
            }

            string url = $"{apiUrl}/api/score";
            ScorePayload payload = new ScorePayload
            {
                board_id = boardId,
                player_id = playerId,
                player_name = playerName,
                score = score,
                metadata = metadataJson
            };

            string json = JsonUtility.ToJson(payload);
            byte[] bodyRaw = Encoding.UTF8.GetBytes(json);

            using (UnityWebRequest request = new UnityWebRequest(url, "POST"))
            {
                request.uploadHandler = new UploadHandlerRaw(bodyRaw);
                request.downloadHandler = new DownloadHandlerBuffer();
                request.SetRequestHeader("Content-Type", "application/json");

                yield return request.SendWebRequest();

                if (request.result != UnityWebRequest.Result.Success)
                {
                    OnScoreSubmitted?.Invoke(false, request.error);
                }
                else
                {
                    string responseText = request.downloadHandler.text;
                    SubmitResponse res = JsonUtility.FromJson<SubmitResponse>(responseText);
                    bool isSuccess = res != null && res.success;
                    string msg = isSuccess ? res.message : (res != null ? res.error : "Unknown error");
                    OnScoreSubmitted?.Invoke(isSuccess, msg);
                }
            }
        }

        public void FetchLeaderboard(string period = "all", int limit = 50)
        {
            StartCoroutine(FetchLeaderboardRoutine(period, limit));
        }

        private IEnumerator FetchLeaderboardRoutine(string period, int limit)
        {
            if (string.IsNullOrEmpty(apiUrl))
            {
                Debug.LogError("[LeaderboardManager] API URL is not configured!");
                OnLeaderboardLoaded?.Invoke(period, new List<ScoreItem>());
                yield break;
            }

            string url = $"{apiUrl}/api/leaderboard?board_id={boardId}&period={period}&limit={limit}";

            using (UnityWebRequest request = UnityWebRequest.Get(url))
            {
                yield return request.SendWebRequest();

                if (request.result != UnityWebRequest.Result.Success)
                {
                    Debug.LogError($"[LeaderboardManager] Fetch error: {request.error}");
                    OnLeaderboardLoaded?.Invoke(period, new List<ScoreItem>());
                }
                else
                {
                    string responseText = request.downloadHandler.text;
                    // JsonUtilityのリスト対応のため、もし必要ならパースを調整するが、
                    // JsonUtility.FromJson はトップレベルの List に直接対応していないため、
                    // 上記で作成した LeaderboardResponse Wrapper に入れることで正常にデシリアライズ可能！
                    LeaderboardResponse res = JsonUtility.FromJson<LeaderboardResponse>(responseText);
                    if (res != null && res.leaderboard != null)
                    {
                        OnLeaderboardLoaded?.Invoke(period, res.leaderboard);
                    }
                    else
                    {
                        OnLeaderboardLoaded?.Invoke(period, new List<ScoreItem>());
                    }
                }
            }
        }
    }
}
