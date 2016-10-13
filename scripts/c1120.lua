--船見まり
--①：このカードが召喚・特殊召喚に成功した時、自分はデッキからカードを1枚ドローする。
--②：このカードが相手によって破壊された時、デッキから「船見結衣」1人を特殊召喚できる。

function c1120.initial_effect(c)

	-- draw
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1120, 0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetOperation(c1120.e1operation)
	c:RegisterEffect(e1)
	local e2 = e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)

	-- special summon
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1120, 1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c1120.e3condition)
	e3:SetTarget(c1120.e3target)
	e3:SetOperation(c1120.e3operation)
	c:RegisterEffect(e3)

end

function c1120.e1operation(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
		Duel.Draw(p, d, REASON_EFFECT) -- 自分はデッキからカードを1枚ドローする
	end
end

function c1120.e3condition(e, tp, eg, ep, ev, re, r, rp)
	return rp ~= tp and e:GetHandler():GetPreviousControler() == tp
end

function c1120.e3filter(c, e, tp)
	return c:IsCode(1020) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function c1120.e3target(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_DECK) and chkc:IsControler(tp) and c1120.e3filter(chkc, e, tp) end
	if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
		and Duel.IsExistingTarget(c1120.e3filter, tp, LOCATION_DECK, 0, 1, nil, e, tp) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectTarget(tp, c1120.e3filter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function c1120.e3operation(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
	end
end
